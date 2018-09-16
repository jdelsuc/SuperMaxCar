extends TextureRect

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	for b in get_children():
		if not b is Button:
			continue
		print("connect to "+b.name)
		b.connect("pressed", self, "on_button_pressed", [b.name] )

func on_button_pressed(name):

	match name:
		
		"GenBut":
			get_tree().change_scene("res://assets/GUI/GenUI.tscn")
			
		"PlayNewBut":
			get_tree().change_scene("res://CarEditor.tscn")

		"ContBut":
			print("Continue game")


		"OptBut":
			print("Changing game options")
		"ExitBut":
			print("Exiting game")



	
	