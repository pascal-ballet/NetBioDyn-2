tool
extends EditorPlugin

const ScNetBioDyn2 = preload("res://addons/NetBioDyn-2/ScBioDyn2.tscn")
var main_panel:VBoxContainer = null
var treeAgents:Tree = null

func _enter_tree() -> void:
	main_panel = ScNetBioDyn2.instance()
	get_editor_interface().get_editor_viewport().add_child(main_panel)
	treeAgents = main_panel.find_node("TreeAgents", true, true)
	print("trouvé", treeAgents)
	var agt:TreeItem = treeAgents.create_item()
	agt.set_text(0, "Agents")
	#treeAgents.set_hide_root(true)
	var child1 = treeAgents.create_item(agt)
	child1.set_text(0, "Child1")
		#var child2 = treeAgents.create_item(agt)
	#treeAgents.add_item("Agent 1", null, true)
	#treeAgents.add_item("Agent 2", null, true)
	var subchild1 = treeAgents.create_item(child1)
	subchild1.set_text(0, "Subchild1")

	#listAgents.rect_min_size = Vector2(500,0)
	#listAgents.rect_min_size()
	make_visible(false)

func _exit_tree() -> void:
	if main_panel:
		main_panel.queue_free()
		
func has_main_screen() -> bool:
	return true
	
func make_visible(visible: bool) -> void:
	if main_panel:
		main_panel.visible = visible
	
func get_plugin_name() -> String:
	return "NetBioDyn-2"

func get_plugin_icon() -> Texture:
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")

