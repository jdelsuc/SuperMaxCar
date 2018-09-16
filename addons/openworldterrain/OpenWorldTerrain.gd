tool
extends EditorPlugin

func _enter_tree():
    # Initialization of the plugin goes here
    # Add the new type with a name, a parent type, a script and an icon
    add_custom_type("WideTerrain", "Node", preload("WideTerrain.gd"), preload("terrain.png"))
    add_custom_type("TerrainCache", "Node", preload("TerrainCache.gd"), preload("terrain.png"))
    add_custom_type("WorldConfig", "Node", preload("WorldConfig.gd"), preload("terrain.png"))


func _exit_tree():
    # Clean-up of the plugin goes here
    # Always remember to remove it from the engine when deactivated
	remove_custom_type("WideTerrain")
	remove_custom_type("WorldConfig")
	remove_custom_type("TerrainCache")
	