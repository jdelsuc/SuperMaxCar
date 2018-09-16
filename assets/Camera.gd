extends Camera

export var max_dist = 15.0

var car

func _ready():
	car = get_node("../TheCar")
	
func _process(delta):
	
	if not car or not car.visible:
		return
	
	var target = car.get_transform().origin

	
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
