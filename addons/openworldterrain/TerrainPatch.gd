tool
extends MeshInstance

export(Image) var height_map
export(Material) var mat


export(Vector2) var offset 			= Vector2( 0, 0 )
export(Vector2) var size 			= Vector2( 32, 32 )
export(float) var h_factor 			= 4.0
export(float) var v_factor 			= 100.0
export(Vector2) var uv_beg			= Vector2(0.0,0.0)
export(Vector2) var uv_end			= Vector2(1.0,1.0)

var shape_owner


func add_vertex(s,img,i,j):	
	var color = img.get_pixel(offset.x+i,offset.y+j)	
	var v     = Vector3(i*h_factor,color.gray()*v_factor,j*h_factor)
#	var v     = Vector3(i*h_factor,0,j*h_factor)
	var uv    = Vector2(
					uv_beg.x+i*(uv_end.x-uv_beg.x)/size.x,
					uv_beg.y+j*(uv_end.y-uv_beg.y)/size.y
					)
#	var uv = Vector2(i/size.x, j/size.y)

	s.add_uv(uv)
	s.add_vertex(v)

func _enter_tree():

		
	var surfaceTool = SurfaceTool.new();
	surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	surfaceTool.add_smooth_group(true)	

	var xmax = size.x
	while xmax+offset.x > height_map.get_width():
		xmax-=1

	var  ymax = size.y
	while ymax+offset.x > height_map.get_height():
		ymax-=1

	height_map.lock()		
	for i in range(xmax):
		for j in range(ymax):
			add_vertex(surfaceTool,height_map,i,j)
			add_vertex(surfaceTool,height_map,i+1,j)
			add_vertex(surfaceTool,height_map,i,j+1)
			add_vertex(surfaceTool,height_map,i+1,j+1)
			add_vertex(surfaceTool,height_map,i,j+1)
			add_vertex(surfaceTool,height_map,i+1,j)
	height_map.unlock()


	surfaceTool.set_material(mat)
	surfaceTool.index()
	surfaceTool.generate_normals()
	surfaceTool.generate_tangents()
	mesh = surfaceTool.commit()			

	var p = get_node("..")
	
	shape_owner = p.create_shape_owner(self)
	p.shape_owner_add_shape(shape_owner, mesh.create_trimesh_shape())
	p.shape_owner_set_transform(shape_owner, transform)

#	create_trimesh_collision()
#	create_convex_collision()

#	coll = ConcavePolygonShape.new()
#	coll.set_faces( mesh.get_faces() )
#
#
#	get_node("..").add_child(coll)
#
#
func _exit_tree():
	var p = get_node("..")
	p.shape_owner_clear_shapes(shape_owner)
	p.remove_shape_owner(shape_owner)
#	get_node("..").remove_child(coll)
	
	
	
	
	


