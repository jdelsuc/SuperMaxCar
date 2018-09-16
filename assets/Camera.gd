extends Camera

export var max_dist = 15.0

var car

func _ready():
	car = weakref(get_node("../TheCar"))
	print("ready")
	
func _process(delta):
	
	var c=car.get_ref()
	if not c:
		car = weakref(get_node("../TheCar"))
		c=car.get_ref()
	
	if not c:
		return
	
	if not c.visible:
		return
	
	var target = c.get_transform().origin

	
	var cam = transform.origin
	
	transform.origin = Vector3(cam.x,target.y+10,cam.z)
	cam = transform.origin
	"res://addons/openworldterrain/terrain.png"
	if max_dist>0:
		var dist = target.distance_to(cam)
		if dist>max_dist :
			var n = (target-cam).normalized()
			n.y=0		
			transform.origin += n*(dist-max_dist)
	
	look_at(target, Vector3(0,1,0))
