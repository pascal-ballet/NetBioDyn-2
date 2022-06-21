extends Node

var _pm:PopupMenu
var _treeAgents:Tree 
enum Prop {EMPTY, ENTITY, BEHAVIOR, GRID, ENV }

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Tree of entities
	_treeAgents = find_node("TreeAgents", true, true)
	_treeAgents.set_hide_root(false)
	addTaxon("Racine")
	
	_pm = $PopupMenu
	
# Entities
# ********
func addAgent(var name) -> void:	
	# Selected node
	var parent:TreeItem = _treeAgents.get_selected()
	
	# Create new Agent
	var agt:TreeItem = _treeAgents.create_item(parent)
	agt.set_text(0, name)
	agt.set_meta("type","Agent")

func addTaxon(var name) -> void:
	# Selected node
	var parent:TreeItem = _treeAgents.get_selected()
	
	# Create new Agent
	var txn:TreeItem = _treeAgents.create_item(parent)
	txn.set_text(0, name)
	txn.set_meta("type","Taxon")
	
func _on_ToolPlusAgent_pressed() -> void:
	var btn_add = get_node("VBoxFrame/HBoxWindows/HSplitContainer/HSplitContainer2/HSplitContainer/VBoxAgentsGp/HBoxAddAgents/BtnAddAgent")
	_pm.popup(Rect2(btn_add.get_position().x, btn_add.get_position().y, _pm.rect_size.x, _pm.rect_size.y))

func _on_PopupMenu_index_pressed(index: int) -> void:
	if index == 0:
		addAgent("Agent")
	if index == 1:
		addTaxon("Taxon")
	pass # Replace with function body.

func _on_BtnDelAgent_pressed() -> void:
	# Selected item
	var selected:TreeItem = _treeAgents.get_selected()
	if selected == null:
		return
	var parent = selected.get_parent()
	if parent == null:
		return
	parent.remove_child(selected)
	selected.free()

func _on_TreeAgents_item_selected() -> void:
	var tabs:TabContainer = get_node("VBoxFrame/HBoxWindows/HSplitContainer/TabContainer")
	tabs.current_tab = Prop.ENTITY

func _on_TreeAgents_focus_entered() -> void:
	var selected_entity = _treeAgents.get_selected()
	if selected_entity != null:
		var tabs:TabContainer = get_node("VBoxFrame/HBoxWindows/HSplitContainer/TabContainer")
		tabs.current_tab = Prop.ENTITY
	
# Behaviors
# *********
func _on_BtnAddBehav_pressed() -> void:
	var lst:ItemList = get_node("VBoxFrame/HBoxWindows/HSplitContainer/HSplitContainer2/HSplitContainer/VBoxAgentsBehav/ListBehav")
	lst.add_item("Comportement")
	lst.set_item_metadata(lst.get_item_count()-1, "Reaction") # type of the item

func _on_BtnDelBehav_pressed() -> void:
	var lst:ItemList = get_node("VBoxFrame/HBoxWindows/HSplitContainer/HSplitContainer2/HSplitContainer/VBoxAgentsBehav/ListBehav")
	var sel:PoolIntArray = lst.get_selected_items()
	if sel.size() > 0:
		lst.remove_item(sel[0])

func _on_ListBehav_item_selected(index: int) -> void:
	var tabs:TabContainer = get_node("VBoxFrame/HBoxWindows/HSplitContainer/TabContainer")
	tabs.current_tab = Prop.BEHAVIOR
		
# Groups
# *********
func _on_BtnAddGp_pressed() -> void:
	var lst:ItemList = get_node("VBoxFrame/HBoxWindows/HSplitContainer/HSplitContainer2/HSplitContainer/VBoxAgentsGp/ListGp")
	lst.add_item("Groupe")
	lst.set_item_metadata(lst.get_item_count()-1, "Reaction") # type of the item

func _on_BtnDelGp_pressed() -> void:
	var lst:ItemList = get_node("VBoxFrame/HBoxWindows/HSplitContainer/HSplitContainer2/HSplitContainer/VBoxAgentsGp/ListGp")
	var sel:PoolIntArray = lst.get_selected_items()
	if sel.size() > 0:
		lst.remove_item(sel[0])

# Grids
# *********
func _on_BtnAddGrid_pressed() -> void:
	var lst:ItemList = get_node("VBoxFrame/HBoxWindows/HSplitContainer/HSplitContainer2/HSplitContainer/VBoxAgentsBehav/ListGrids")
	lst.add_item("Grille")
	lst.set_item_metadata(lst.get_item_count()-1, "Reaction") # type of the item

func _on_BtnDelGrid_pressed() -> void:
	var lst:ItemList = get_node("VBoxFrame/HBoxWindows/HSplitContainer/HSplitContainer2/HSplitContainer/VBoxAgentsBehav/ListGrids")
	var sel:PoolIntArray = lst.get_selected_items()
	if sel.size() > 0:
		lst.remove_item(sel[0])

func _on_ListGrids_item_selected(index: int) -> void:
	var tabs:TabContainer = get_node("VBoxFrame/HBoxWindows/HSplitContainer/TabContainer")
	tabs.current_tab = Prop.GRID
	
# Env
# *********
func _on_Button_pressed() -> void:
	var tabs:TabContainer = get_node("VBoxFrame/HBoxWindows/HSplitContainer/TabContainer")
	tabs.current_tab = Prop.ENV

