extends Camera

export var max_dist = 15.0

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _process(delta):
	
	var target = get_node("../TheCar").get_transform().origin
	#var target = get_node("../TestCar").get_transform().origin
	
	
	
	var cam = transform.origin
	
	transform.origin = Vector3(cam.x,target.y+10,cam.z)
	cam = transform.origin
	
	if max_dist>0:
		var dist = target.distance_to(cam)
		if dist>max_dist :
			var n = (target-cam).normalized()
			n.y=0		
			transform.origin += n*(dist-max_dist)
	
	
	
	look_at(target, Vector3(0,1,0))
