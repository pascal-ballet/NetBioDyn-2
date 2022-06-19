extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var _pm

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	addAgent()
	_pm = $PopupMenu
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func addAgent() -> void:
	var treeAgents = find_node("TreeAgents", true, true)
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

func addTaxon() -> void:
	pass
	
func _on_ToolPlusAgent_pressed() -> void:
	var btn_add = get_node("VBoxFrame/HBoxWindows/HSplitContainer/HSplitContainer2/HSplitContainer/VBoxAgentsGp/HBoxAddAgents/ToolPlusAgent")
	_pm.popup(Rect2(btn_add.get_position().x, btn_add.get_position().y, _pm.rect_size.x, _pm.rect_size.y))
	

func _on_PopupMenu_index_pressed(index: int) -> void:
	if index == 0:
		addAgent()
	if index == 1:
		addTaxon()
	pass # Replace with function body.
