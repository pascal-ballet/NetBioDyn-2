tool
extends EditorPlugin

var ScNetBioDyn2 = preload("res://addons/NetBioDyn-2/ScBioDyn2.tscn")

var main_panel:VBoxContainer = null
var treeAgents:Tree = null

func _enter_tree() -> void:
	# Instance a ScBioDyn2 scene
	main_panel = ScNetBioDyn2.instance()
	# Add the scene to the interface of Godot
	get_editor_interface().get_editor_viewport().add_child(main_panel)
	# Get the scene tree of NetBioDyn scene
	treeAgents = main_panel.find_node("TreeAgents", true, true)
	# create a new node type: Agent
	add_custom_type("NBD_Agent", "Node", preload("res://addons/NetBioDyn-2/7-Engine/agent.gd"), preload("res://addons/NetBioDyn-2/7-Engine/agent.png"))
	# Hide NetBioDyn from the main godot gui (must be done)
	make_visible(false)

func _exit_tree() -> void:
	if main_panel:
		main_panel.queue_free()
	remove_custom_type("NBD_Agent")
			
func has_main_screen() -> bool:
	return true
	
func make_visible(visible: bool) -> void:
	if main_panel:
		main_panel.visible = visible
	
func get_plugin_name() -> String:
	return "NetBioDyn-2"

func get_plugin_icon() -> Texture:
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")

