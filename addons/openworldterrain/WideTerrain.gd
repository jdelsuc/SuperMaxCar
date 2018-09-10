tool
extends StaticBody

#the car which is followed for terrain loading
export(NodePath) 		var the_car = "/root/Editor/TheCar"

#the image that contains the heigths
export(String,FILE) 	var height_map 	= "res://heights.png"

#the scaling h_factor (ratio between image coord and world coord)
export(float)			var h_factor 		= 4.0

#the scaling v_factor (ratio between image coord and world coord)
export(float)			var v_factor 		= 100.0


#the size of a patch in image pixel
export(Vector2)			var patch_size	= Vector2( 32, 32 )

#between world coord and map coord, in patch size
export(Vector2)			var offset = Vector2( 16, 16 )

#export the material to apply
export(Material) 		var mat

var car 
var hm_img
var cur_patch
var patches = []
var row_size
var col_size
var world_offset

var car_pos_in_img setget set_car_pos_in_img, get_car_pos_in_img


# Foreign Classes
const TerrainPatch = preload("TerrainPatch.gd")

func _enter_tree():

	hm_img = Image.new()
	hm_img.load(height_map)

	row_size = 	hm_img.get_width()/patch_size.x
	col_size = hm_img.get_height()/patch_size.y
	for i in range(row_size):
		var col = []
		for j in range(col_size):
			col.append(null)
		patches.append( col )
	car = get_node(the_car)
	world_offset = Vector3(offset.x*patch_size.x*h_factor,0,offset.y*patch_size.y*h_factor)



		

func load_patch(i,j):
	
	if (i<0 or j<0 or i>=row_size or j>=col_size):
		return #out of bounds
	
	if patches[i][j] != null:
		return #already loaded
	
	#print("Loading : ",Vector2(i,j))
	
	var patch = TerrainPatch.new()
	patch.height_map = hm_img
	patch.size = patch_size
	patch.offset = Vector2( i*patch_size.x, j*patch_size.y)
	patch.h_factor = h_factor
	patch.v_factor = v_factor
	patch.mat = mat
	patch.uv_beg = Vector2( i/row_size, j/row_size)
	patch.uv_end = Vector2( (i+1)/row_size, (j+1)/col_size)
	
	
	var pos = Vector2(i,j)
	pos -= offset
	patch.transform.origin = Vector3(pos.x*patch_size.x*h_factor,0,pos.y*patch_size.y*h_factor)
	patch.name = "patch"	
	patches[i][j]=patch
	add_child(patch,true)
	
	
	return patch

func remove_patch(i,j):
	if i<0 or i>=row_size or j<0 or j>=col_size:
		return
	var patch = patches[i][j]
	if patch == null:
		return
		
	#print("Removing : ",Vector2(i,j))
	remove_child(patch)
	patches[i][j] = null
	
func remove_useless_patches():
	if cur_patch == null:
		return
	for i in range(cur_patch.x-3,cur_patch.x+4):
		remove_patch(i,cur_patch.y+3)
		remove_patch(i,cur_patch.y-3)

	for j in range(cur_patch.y-3,cur_patch.y+4):
		remove_patch(cur_patch.x+3,j)
		remove_patch(cur_patch.x-3,j)

func load_new_patches(isinit):
	if (cur_patch == null):
		return
		
	for i in range(cur_patch.x-2,cur_patch.x+3):
		for j in range(cur_patch.y-2,cur_patch.y+3):
			load_patch(i,j)
			if not isinit:
				yield(get_tree(),"idle_frame")
				
func pos_to_ij(pos):
	var xypos = pos / h_factor
	var ijpos = Vector2( 
		int(xypos.x/patch_size.x), 
		int(xypos.z/patch_size.y)
	)
	ijpos += offset
	return ijpos
	

func update_curpatch():
	if car == null:
		return
	
	var prev = cur_patch
		
	cur_patch = pos_to_ij(car.transform.origin)
	
	return cur_patch!=prev
	
	
func from_world_to_img(pos):
	pos+=world_offset
	pos/=h_factor
	return Vector2(int(pos.x),int(pos.z))
	
	
func get_height(pos):
	hm_img.lock()
	pos = from_world_to_img(pos)
	var h = hm_img.get_pixel(pos.x,pos.y).gray()
	return h*v_factor
	
	
		

func _ready():
	update_curpatch()
	#load surrounding patches
	load_new_patches(true)	
	
	var o = car.transform.origin
	#print(get_height(o))
	car.transform.origin = Vector3(o.x,get_height(o)+1,o.z)
	
	
#	print (from_world_to_img(car.transform.origin))
	print_tree_pretty()

func get_car_pos_in_img():
	return from_world_to_img(car.transform.origin)
	
func set_car_pos_in_img(value):
	pass #this is a read-only variable	


func _process(delta):
	#get the current car location
#	pass
	if update_curpatch():
		remove_useless_patches()
		yield(load_new_patches(false),"completed")
	

