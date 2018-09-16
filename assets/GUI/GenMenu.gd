extends TextureRect

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	get_node( "Button" ).connect( "pressed", self, "_gen_button_pressed" )
	get_node( "Button2" ).connect( "pressed", self, "_exit_button_pressed" )

func _process(delta):
	var main_pg = get_node("MainPg")
	var sub_pg = get_node("SubPg")
	var cache = get_node("/root/GenUI/TerrainCache")
	
	main_pg.value = cache.prog
	sub_pg.value = cache.sub_prog
	
func _gen_button_pressed():
	var cache = get_node("/root/GenUI/TerrainCache")
	
	if cache.busy:
		print("busy")
		return
	
	cache.generate_new_world()	

func _exit_button_pressed():
	var cache = get_node("/root/GenUI/TerrainCache")

	if cache.busy:
		print("busy")
		return
	
	get_tree().change_scene("res://assets/GUI/MainMenu.tscn")
	