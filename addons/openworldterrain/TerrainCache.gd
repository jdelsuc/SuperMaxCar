###################################################################################
## This cache implements a cache that manages terrain patches
##################################################################################
extends Node #inherits from node so we can put it inside the tree

#Imports
const TerrainPatch 	= preload("TerrainPatch.gd")
const CacheQueue 	= preload("CacheQueue.gd")
const WorldConfig	= preload("WorldConfig.gd") 

var need_refresh = false #if one of the configuration files changed every thing must be generated again
var cache_dir = "res://cache/"

var patches = []


var rbi = []
var gbi = []
var bbi = []


var hm_img
var bm_img
var mat_res
var lib_res

var row_size
var col_size
var world_offset

var the_world

var loading_queue


var prog = 0
var sub_prog = 0
var busy = false


var the_config

const MAX_THREADS = 1
var threads = []
var loader

######################################
## Event handlers
######################################
func _enter_tree():
		
	get_tree().connect( "node_added", self, "_on_node_change")
	get_tree().connect( "node_removed", self, "_on_node_change")
	
	#check if configuration is present else generate warning
	update_config()
		
func _exit_tree():
	get_tree().disconnect( "node_added", self, "_on_node_change")
	get_tree().disconnect( "node_removed", self, "_on_node_change")
	
func _on_node_change(node):
	
	if not node	in get_children():
		return
	
	if not node is WorldConfig:
		return
	
	update_config()

########################
# Public Methods
########################
func generate_new_world():
	
	busy = true
	clear_cache()
	generate_data()

	var imax = hm_img.get_width() / the_config.patch_size.x
	var jmax = hm_img.get_height() / the_config.patch_size.y
	for i in range( imax ):
		prog = int(float(i)/imax*100)
		for j in range( jmax ):
			sub_prog = int(float(j)/jmax*100)
			generate_patch(i,j)
			yield(get_tree(), "idle_frame")
		sub_prog = 100
	prog = 100
	busy = false

	var scene = PackedScene.new()
	scene.pack(the_config)
	ResourceSaver.save(cache_dir+"config.tscn", scene) 		


func _thread_main(num):	
	print("Loader thread %d started" % num)
	while true :
		loading_queue.process(num)

func display_patch(patch):
	print( "display %s" % patch )
	the_world.add_child(patch)


func _process_patch( patch_vector ):
	
	if patches[patch_vector.x][patch_vector.y]:
		print( "%s already loaded" % patch_vector )
		return
	
	var name ="patch_%d_%d.tscn" % [patch_vector.x,patch_vector.y]


	var file = File.new()
	if not file.file_exists(cache_dir+name):
		print("%s does not exist" % [cache_dir+name])
		return
	print( "%s loading" % [cache_dir+name] )
	var patch = load( cache_dir + name ).instance()
	print( "%s loaded" % name )
	patches[patch_vector.x][patch_vector.y] = patch
	var pos = patch_vector
	pos -= the_config.offset
	patch.transform.origin = Vector3(
									pos.x*the_config.patch_size.x*the_config.h_factor,
									0,
									pos.y*the_config.patch_size.y*the_config.h_factor
								)

	call_deferred("display_patch", patch)
	
	
func play_the_world(the_world):
	
	self.the_world = the_world
	
	#load the config
	the_config = load(cache_dir+"config.tscn").instance()
	add_child(the_config)

	generate_data()

	loading_queue = CacheQueue.new("Loading", self, "_process_patch" )

	for i in range(MAX_THREADS):	
		var thread = Thread.new()
		threads.append(thread)	
		thread.start( self, "_thread_main",i )

func from_world_to_img(pos):
	pos+=world_offset
	pos/=the_config.h_factor
	return Vector2(floor(pos.x),floor(pos.z))

func get_height(pos):
	pos = from_world_to_img(pos)	
	hm_img.lock()
	var h = hm_img.get_pixel(pos.x,pos.y).gray()
	hm_img.unlock()
	return h * the_config.v_factor

func pos_to_ij(pos):
	var xypos = pos / the_config.h_factor
	var ijpos = Vector2( 
		int(floor(xypos.x/the_config.patch_size.x)), 
		int(floor(xypos.z/the_config.patch_size.y))
	)
	ijpos += the_config.offset
	return ijpos
	

#########################################
## PrivateMethods
#########################################
func generate_data ():
 
	hm_img = Image.new()
	hm_img.load(the_config.height_map)

	bm_img = Image.new()
	bm_img.load(the_config.biome_map)
	
	mat_res = load(the_config.mat)
	lib_res = load(the_config.lib)

	init_array( the_config.red_biome_indexes, rbi )
	init_array( the_config.green_biome_indexes, gbi )
	init_array( the_config.blue_biome_indexes, bbi )

	row_size = hm_img.get_width() / the_config.patch_size.x
	col_size = hm_img.get_height() / the_config.patch_size.y
	for i in range(row_size):
		var col = []
		for j in range(col_size):
			col.append(null)
		patches.append( col )

	world_offset = Vector3(
		the_config.offset.x*the_config.patch_size.x*the_config.h_factor,
		0,
		the_config.offset.y*the_config.patch_size.y*the_config.h_factor
	)


func update_config():
	var curr_conf = the_config
	for n in get_children():
		if n is WorldConfig :
			the_config = n
			break
	return curr_conf != the_config


################################
# Delete all cache files		
################################
func clear_cache():
	var dir = Directory.new()
	dir.open( cache_dir )
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while (file_name != ""):
		if file_name.match("patch_*"):
			dir.remove(file_name)
		file_name = dir.get_next()


func init_array(arr1,arr2):
	for k in arr1:
		var idx = lib_res.find_item_by_name(k)
		if (idx<0) :
			print ("bad biome element : " + k)
			return
		var sub = [lib_res.get_item_mesh(idx),
					lib_res.get_item_shapes(idx)]
		for i in range(arr1[k]):
			arr2.append(sub)


func generate_patch(i,j):

	if (i<0 or j<0 or i>=row_size or j>=col_size):
		print("out of bonds")
		return #out of bounds


	print( "generate %d,%d" % [i,j] )

	var patch = TerrainPatch.new(self,i,j)
	patch.build_surface()
	patch.build_biome()
	patch.name = "patch_%d_%d" % [i,j]	

	var scene = PackedScene.new()
	scene.pack(patch)
	ResourceSaver.save(cache_dir+patch.name+".tscn", scene) 		

	return patch

func load_patch(i,j):
	loading_queue.push(	Vector2(i,j) )

func remove_patch(i,j):
	if patches[i][j] == null:
		return
	
	the_world.remove_child(patches[i][j])
	
	patches[i][j] = null

