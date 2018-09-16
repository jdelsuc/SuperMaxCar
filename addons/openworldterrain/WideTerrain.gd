extends Node

# Foreign Classes
const TerrainPatch = preload("TerrainPatch.gd")
const TerrainCache = preload("TerrainCache.gd")

#the car which is followed for terrain loading
export(NodePath) 		var the_car = "/root/Editor/TheCar"


var car 
var cur_patch

var cache

var car_pos_in_img setget set_car_pos_in_img, get_car_pos_in_img

var is_ready


func _enter_tree():

	is_ready = false

func remove_useless_patches():
	if cur_patch == null:
		return
	for i in range(cur_patch.x-3,cur_patch.x+4):
		cache.remove_patch(i,cur_patch.y+3)
		cache.remove_patch(i,cur_patch.y-3)

	for j in range(cur_patch.y-3,cur_patch.y+4):
		cache.remove_patch(cur_patch.x+3,j)
		cache.remove_patch(cur_patch.x-3,j)

func load_new_patches(isinit):
	if (cur_patch == null):
		return

	cache.load_patch(cur_patch.x,cur_patch.y)

	cache.load_patch(cur_patch.x,cur_patch.y-1)
	cache.load_patch(cur_patch.x,cur_patch.y+1)
	cache.load_patch(cur_patch.x-1,cur_patch.y)
	cache.load_patch(cur_patch.x+1,cur_patch.y)


	cache.load_patch(cur_patch.x-1,cur_patch.y-1)
	cache.load_patch(cur_patch.x+1,cur_patch.y-1)
	cache.load_patch(cur_patch.x-1,cur_patch.y+1)
	cache.load_patch(cur_patch.x+1,cur_patch.y+1)
	


func update_curpatch():
	if car == null:
		return
	
	var prev = cur_patch
	cur_patch = cache.pos_to_ij(car.transform.origin)
	return cur_patch!=prev
	

func _ready():

	cache	 = null
	
	for c in get_children():
		if c is TerrainCache:
			cache = c
			break	

	cache.play_the_world(self)
	

	car = get_node(the_car)
	if car:
		car.hide()

	update_curpatch()
	#load surrounding patches
	load_new_patches(true)	

	
	
#	print (from_world_to_iyg(car.transform.origin))
#	print_tree_pretty()

func get_car_pos_in_img():
	return cache.from_world_to_img(car.transform.origin)
	
func set_car_pos_in_img(value):
	pass #this is a read-only variable	


func _process(delta):
	#get the current car location

	if not cache :
		return

	if get_child_count()==0:
		return
	
	if not is_ready:		
		is_ready = true
		var o = car.transform.origin
		car.transform.origin = Vector3(o.x,cache.get_height(o)+1,o.z)
		car.show()
	else :
#		update_curpatch()
		if update_curpatch():
			remove_useless_patches()
			load_new_patches(false)
	

