tool
extends VehicleBody

# Proportions of different parts of the image
export var wheel_radius			= 0.15
export var size 				= 1.0
export var height 				= 0.5
export var hood_height_ratio	= 0.5
export var hood_curve_ratio		= 0.3
export var cockpit_begin_ratio	= 0.4
export var cockpit_end_ratio	= 0.8
export var trunk_curve_ratio	= 0.9
export var trunk_height_ratio	= 0.4
export var engine_max			= 120

#Images to be mapped to different part of the car
export(String, FILE) var front_img 			= "res://front.png"
export(String, FILE) var hood_img 			= "res://hood.png"
export(String, FILE) var front_glass_img 	= "res://glass.png"
export(String, FILE) var roof_img 			= "res://roof.png"
export(String, FILE) var back_glass_img 	= "res://glass.png"
export(String, FILE) var trunk_img 			= "res://hood.png"
export(String, FILE) var back_img 			= "res://back.png"
export(String, FILE) var bottom_img 		= "res://bottom.png"
export(String, FILE) var side_img 			= "res://side.png"


#internal vars
var top_curve
var bottom_curve
var nv
var ratios = []


func circle(t,tb,te,size):
	return size*sin(PI*(t-tb)/(te-tb))


func add_face(s,inv,uvdelta,v1,v2,v3,v4,uv1,uv2,uv3,uv4):
	uv1.x = uv1.x/3+uvdelta
	uv2.x = uv2.x/3+uvdelta
	uv3.x = uv3.x/3+uvdelta
	uv4.x = uv4.x/3+uvdelta
	
	#1st face
	s.add_uv(uv1);
	s.add_vertex(v1)
	if not inv:
		s.add_uv(uv2);
		s.add_vertex(v2)
	
		s.add_uv(uv3);
		s.add_vertex(v3)
	else:
		s.add_uv(uv3);
		s.add_vertex(v3)

		s.add_uv(uv2);
		s.add_vertex(v2)
	
		
	#2nd face
	s.add_uv(uv3);
	s.add_vertex(v3)

	if not inv:
		s.add_uv(uv4);
		s.add_vertex(v4)
	
		s.add_uv(uv1);
		s.add_vertex(v1)
	else:
		s.add_uv(uv1);
		s.add_vertex(v1)

		s.add_uv(uv4);
		s.add_vertex(v4)
	
		


func _gen_surf(s, inv,points, uvdelta):
	var nv = len(points)
	for t in range(0, nv-1):
		var uv1=Vector2( float(t)/nv,0)
		var uv2=Vector2( float(t)/nv,1)
		var uv3=Vector2( (float(t)+1)/nv,1)
		var uv4=Vector2( (float(t)+1)/nv,0)

		var v1=Vector3(
			-size/2,
			points[t].y,
			points[t].x-size
			)
		var v2=Vector3(
			size/2,
			points[t].y,
			points[t].x-size
			)
		var v3=Vector3(
			size/2,
			points[t+1].y,
			points[t+1].x-size
			)
		var v4=Vector3(
			-size/2,
			points[t+1].y,
			points[t+1].x-size
			)
		
		add_face(s,inv,uvdelta,v1,v2,v3,v4,uv1,uv2,uv3,uv4)




func gen_bottom(s):
	var wheel = (wheel_radius*nv)/(2*size)
	var tb1 = wheel
	var te1 = tb1+2*wheel
	var te2 = nv-wheel
	var tb2 = te2-2*wheel
	var y = 0

	bottom_curve = []

	for t in range(0,nv+1):
		
		if (t>tb1 and t<te1):
			y = circle(t,tb1,te1,wheel_radius)
		elif (t>tb2 and t<te2):
			y = circle(t,tb2,te2,wheel_radius)
		else:
			y = 0
			
		bottom_curve.append(Vector2(2*float(t)*size/nv,y))

	_gen_surf(s, true, bottom_curve, 0.33)

func gen_top(s):
	var curve = Curve2D.new()

	var points = [
		Vector2(0, 0),
		Vector2(0, 100*hood_height_ratio*height),

		Vector2(100*size*2*hood_curve_ratio,
			100*hood_height_ratio*height),
		Vector2(100*size*2*cockpit_begin_ratio,
			100*height),
		Vector2(100*size*2*cockpit_end_ratio,
			100*height),
		Vector2(100*size*2*cockpit_end_ratio,
			100*trunk_height_ratio*height),
		Vector2(100*size*2*trunk_curve_ratio,
			100*trunk_height_ratio*height),

		Vector2(100*2*size, 0)
	]

	var tot_len = 0
	for i in range(1,len(points)):
		var d = points[i].distance_to(points[i-1])
		ratios.append(d)
		tot_len += d
		
	for i in range(len(ratios)):
		ratios[i]=ratios[i]/tot_len

	curve.add_point(
		points[0],
		Vector2(0,-10),
		Vector2(-10,0)
		)
	for i in range(1,len(points)-1):
		curve.add_point(
			points[i],
			Vector2(-10,0),
			Vector2(0,-10)
		)
	curve.add_point(
		points[-1],
		Vector2(10,0),
		Vector2(0,-10)
		)
			

	var vectors = curve.get_baked_points()
	top_curve = []
	
	for v in vectors:
		top_curve.append(Vector2(v.x/100,v.y/100))

	_gen_surf(s, false,top_curve,0)
	nv = len(top_curve)

func gen_sides(s,x,inv):
	for t in range(nv-1):

		var v1=Vector3(
			x,
			bottom_curve[t].y,
			bottom_curve[t].x-size
			)
		var v2=Vector3(
			x,
			top_curve[t].y,
			top_curve[t].x-size
			)
		var v3=Vector3(
			x,
			top_curve[t+1].y,
			top_curve[t+1].x-size
			)
		var v4=Vector3(
			x,
			bottom_curve[t+1].y,
			bottom_curve[t+1].x-size
			)


		var uv1 = Vector2((v1.z+size)/(size*2),1.0-v1.y/height)
		var uv2 = Vector2((v2.z+size)/(size*2),1.0-v2.y/height)
		var uv3 = Vector2((v3.z+size)/(size*2),1.0-v3.y/height)
		var uv4 = Vector2((v4.z+size)/(size*2),1.0-v4.y/height)

		add_face(s,inv,0.66,v1,v2,v3,v4,uv1,uv2,uv3,uv4)


func add_to_texture(img,path,idx,offset):
	var img2 = Image.new()
	img2.load(path)
	img2.resize(256*ratios[idx],256)
	
	img.blit_rect(
		img2,
		Rect2(0,0,img2.get_width(),img2.get_height()),
		Vector2(offset,0)
		)

	offset += img2.get_width()
	return offset

func gen_texture():
	ratios.append(1.0)
	var img = Image.new()
	img.create(3*256,256,false,Image.FORMAT_RGB8)
	img.lock()
	
	var offset = 0
	offset = 	add_to_texture(img,front_img,0,offset)
	offset = 	add_to_texture(img,hood_img,1,offset)
	offset = 	add_to_texture(img,front_glass_img,2,offset)
	offset = 	add_to_texture(img,roof_img,3,offset)
	offset = 	add_to_texture(img,back_glass_img,4,offset)
	offset = 	add_to_texture(img,trunk_img,5,offset)
	offset = 	add_to_texture(img,back_img,6,offset)
	add_to_texture(img,bottom_img,7,256)
	add_to_texture(img,side_img,7,512)
	
	img.unlock()
	
#	img.save_png("res://test.png")
	var res= ImageTexture.new()
	res.create_from_image(img, ImageTexture.STORAGE_COMPRESS_LOSSLESS )
	return res

func put_wheel(vb,name,origin,traction):
	var w = VehicleWheel.new()
	w.name = "Wheel"+name
	w.wheel_radius = wheel_radius
	w.wheel_rest_length = wheel_radius
	w.transform.origin = origin
	w.transform.origin.y += w.wheel_rest_length
	w.use_as_traction = traction
	w.use_as_steering = traction
	w.suspension_stiffness = 100
	w.suspension_travel = 0.7
	w.suspension_max_force = 100000
	w.rotate_y(PI)

	vb.add_child(w,true)
#	w.set_owner(get_tree().get_edited_scene_root())
	
	var mw = MeshInstance.new()
	mw.mesh=CylinderMesh.new()
	mw.rotate_z(PI/2)
	mw.mesh.top_radius = wheel_radius
	mw.mesh.bottom_radius = wheel_radius
	mw.mesh.height = 0.1
	w.add_child(mw,true)
#	mw.set_owner(get_tree().get_edited_scene_root())
	
	
func put_wheels(vb):
	var o = Vector3(-size/2, 0,-size+2*wheel_radius)
	put_wheel(vb,"FL",o,true)
	
	o.x = size/2
	put_wheel(vb,"FR",o,true)

	o.z = size-2*wheel_radius
	put_wheel(vb,"BR",o,false)

	o.x = -size/2
	put_wheel(vb,"BL",o,false)
	

func _enter_tree():
	#mat.params_cull_mode = SpatialMaterial.CULL_DISABLED
	var vb = self
	var surfaceTool = SurfaceTool.new();
	surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)

	gen_top(surfaceTool)
	gen_bottom(surfaceTool)
	gen_sides(surfaceTool,-size/2,false)
	gen_sides(surfaceTool,size/2,true)
	
	var mesh = MeshInstance.new()

	var mat = SpatialMaterial.new();
	mat.albedo_texture = gen_texture();
	mat.flags_unshaded = false;

	surfaceTool.set_material(mat)
	surfaceTool.generate_normals()
	mesh.mesh = surfaceTool.commit()
	mesh.transform.origin = Vector3(0,0,0)
	
	var shape = BoxShape.new()
	shape.extents = Vector3(size/2,height/2,size)
	var col = CollisionShape.new()
	col.transform.origin = mesh.transform.origin
	col.transform.origin.y += height/2
	col.shape = shape
	
	
	vb.add_child(col,true)
	#col.set_owner(get_tree().get_edited_scene_root())

	vb.add_child(mesh,true)
	#mesh.set_owner(get_tree().get_edited_scene_root())
	
	put_wheels(vb)


func _physics_process(delta):	

	var throttle = 0
	var steer_val = 0
	if Input.is_key_pressed(KEY_UP):
		throttle = 1.0
	if Input.is_key_pressed(KEY_DOWN):
		throttle = -1.0
	if Input.is_key_pressed(KEY_LEFT):
		steer_val = 1.0
	if Input.is_key_pressed(KEY_RIGHT):
		steer_val = -1.0
	
	engine_force = throttle * engine_max
	steering = steer_val * PI/6

