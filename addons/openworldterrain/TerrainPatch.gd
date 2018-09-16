extends MeshInstance

const WorldConfig = preload("WorldConfig.gd")

var height_map
var biome_map
var lib
var mat

var offset 			= Vector2( 0, 0 )
var size 			= Vector2( 32, 32 )
var h_factor 			= 4.0
var v_factor 			= 100.0
var uv_beg			= Vector2(0.0,0.0)
var uv_end			= Vector2(1.0,1.0)
var max_population	= 0.1

var rbi 
var gbi 
var bbi

var the_static

var progress = 0.0
var xmax
var ymax

var cache

var the_config = null


func _init(cache=null, i=0, j=0 ):
		
	if not cache :
		return
	
	size 			= cache.the_config.patch_size
	offset 			= Vector2( 
						i*cache.the_config.patch_size.x, 
						j*cache.the_config.patch_size.y
					)
	h_factor 		= cache.the_config.h_factor
	v_factor 		= cache.the_config.v_factor
	mat 			= cache.mat_res
	lib 			= cache.lib_res
	uv_beg 			= Vector2( i/cache.row_size, j/cache.col_size)
	uv_end 			= Vector2( (i+1)/cache.row_size, (j+1)/cache.col_size)
	rbi 			= cache.rbi
	gbi 			= cache.gbi
	bbi 			= cache.bbi


	xmax = size.x
	while xmax+offset.x > cache.hm_img.get_width():
		xmax-=1


	ymax = size.y
	while ymax+offset.x > cache.bm_img.get_height():
		ymax-=1
	
	var rect = Rect2(offset,Vector2(xmax+1,ymax+1))

	height_map = cache.hm_img.get_rect(rect)
	biome_map = cache.bm_img.get_rect(rect)

	the_static = StaticBody.new()
	add_child(the_static)
	the_static.set_owner(self)


func build_surface():
	height_map.lock()		
	create_surface()
	height_map.unlock()
	


func get_vertex(img,i,j):
	var color = img.get_pixel(i,j)	
	var v     = Vector3(i*h_factor,color.gray()*v_factor,j*h_factor)
	return v

func add_vertex(s,img,i,j):	
	var v     = get_vertex(img, i, j)

	var uv    = Vector2(
					uv_beg.x+i*(uv_end.x-uv_beg.x)/size.x,
					uv_beg.y+j*(uv_end.y-uv_beg.y)/size.y
					)
	s.add_uv(uv)
	s.add_vertex(v)

func create_surface():

	randomize()
	var surfaceTool = SurfaceTool.new();


	surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	surfaceTool.add_smooth_group(true)	

	for i in range(xmax):
		for j in range(ymax):
			add_vertex(surfaceTool,height_map,i,j)
			add_vertex(surfaceTool,height_map,i+1,j)
			add_vertex(surfaceTool,height_map,i,j+1)
			add_vertex(surfaceTool,height_map,i+1,j+1)
			add_vertex(surfaceTool,height_map,i,j+1)
			add_vertex(surfaceTool,height_map,i+1,j)


	surfaceTool.set_material(mat)
	surfaceTool.index()
	surfaceTool.generate_normals()
	surfaceTool.generate_tangents()


	mesh = surfaceTool.commit()
	print(mesh)
	
	var shape = CollisionShape.new() 
	the_static.add_child(shape)
	shape.set_owner(self)
	shape.shape = mesh.create_trimesh_shape()


func put_biome( arr, i, j ) :
	var v = get_vertex(height_map, i, j)
	
	var mi = MeshInstance.new()
	mi.mesh = arr[0]
	mi.transform.origin = v
	add_child(mi)
	mi.set_owner( self )

	if arr[1]:
		var shape = CollisionShape.new() 
		the_static.add_child(shape)
		shape.set_owner(self)
		shape.shape = arr[1][0]
		shape.transform = mi.transform

	

func create_biome(xmax,ymax):
	
	var mx = size.x * size.y * max_population
	for n in range(mx):
		
		progress = float(n)/mx
		
		var i = randi() % int(size.x)
		var j = randi() % int(size.y)

		var color = biome_map.get_pixel(i,j)
		var red_biome 	= color.b
		var green_biome = color.g
		var blue_biome 	= color.b
		
		var m = blue_biome
		var biome = bbi
		if red_biome > green_biome and red_biome > blue_biome :
				m = red_biome
				biome = rbi
		elif green_biome > blue_biome :
			m = green_biome
			biome = gbi
			
		#do we put something ?
		if randf() >= m :
			continue

		var r = randi() % len(biome)
		put_biome(biome[r], i, j)

	progress = 1.0		


	
func build_biome():
	height_map.lock()
	biome_map.lock()
	create_biome(xmax, ymax)
	biome_map.unlock()
	height_map.unlock()


func poll():
	return progress	
	
	
	
	
	
