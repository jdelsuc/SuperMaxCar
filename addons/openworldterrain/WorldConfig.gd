extends Node


#the image that contains the heigths
export(String,FILE) 	var height_map 	= "res://heights.png"

#the image that contains the heigths
export(String,FILE) 	var biome_map 	= "res://biome.png"

#export the material to apply
export(String,FILE) 	var mat = "res://assets/terrain/slatmap.tres"

#the library containing the mesh for the biomes
export(String,FILE) 	var lib = "res://assets/terrain/terrain.meshlib"



#the scaling h_factor (ratio between image coord and world coord)
export(float)			var h_factor 		= 4.0

#the scaling v_factor (ratio between image coord and world coord)
export(float)			var v_factor 		= 100.0


#the size of a patch in image pixel
export(Vector2)			var patch_size	= Vector2( 32, 32 )

#between world coord and map coord, in patch size
export(Vector2)			var offset = Vector2( 16, 16 )


#the repartition of each element inside a biome
export var red_biome_indexes = {
								"Grass1": 	1,
								"Bush":		1,
								"Flower":	3,
								"Rock1":	1,
								"Rock2":	1,
								"Rocks":	2
							}

export var green_biome_indexes = {
								"Grass1": 	1,
								"Grass2":	1,
								"Fence":	1,
								"Bush":		1,
								"Tree1":	2,
								"Tree2":	2,
								"Tree3":	2,
								"Rocks":	1								
							}
export var blue_biome_indexes = {
								"Grass1": 	1,
								"Grass2":	1,
								"Fence":	2,
								"House1":	2,
								"House2":	2,
								"Tree3":	2,
							}
