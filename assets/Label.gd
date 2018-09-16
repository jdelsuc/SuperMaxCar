extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.

	var terrain = get_node("/root/Editor/TheTerrain")

	var p = terrain.car.transform.origin

	var t = String(Vector3(int(p.x),int(p.y),int(p.z))) + "\r\n" 

	t+= String(terrain.car_pos_in_img) + "\r\n" 
	t+= String(terrain.cur_patch) + "\r\n" 	
	t+= String(Performance.get_monitor(Performance.TIME_FPS)) + "\r\n"
	t+= String(Performance.get_monitor(Performance.MEMORY_DYNAMIC_MAX))
	
	text =t

