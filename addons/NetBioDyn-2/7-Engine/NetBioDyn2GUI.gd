# This class is the Controler in the MVC
# The View is scene called ScBioDyn2.tscn
# The Model is the 3D scene

extends Node

var _pm:PopupMenu
var _listAgents:ItemList 
enum Prop {EMPTY, ENTITY, BEHAVIOR, GRID, ENV }

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Tree of entities
	_listAgents = find_node("ListAgents", true, true)
	_pm = $PopupMenu
	
# **********************************************************
# Entities
# **********************************************************
func addAgent(var name) -> void:	
	# Create new Agent in GUI -----------------------------
	var lst:ItemList = _listAgents
	lst.add_item(name)
	lst.set_item_metadata(lst.get_item_count()-1, "Agent") # type of the item
	
	# Create new Agent Type in 3D Scene -----------------------------
	var rb:RigidBody = create_rigid_body_agent(name)
	var node_entities:Node = get_node("%Entities")

	#  - add the Agent to the scene
	node_entities.add_child(rb)
	rb.set_owner(get_node("%Simulator"))
	
func create_rigid_body_agent(var name:String) -> RigidBody:
	#  - material
	var mat:SpatialMaterial = SpatialMaterial.new()
	mat.albedo_color = Color(1.0, 0.0, 0.0, 1.0)
	#  - mesh
	var mh:MeshInstance = MeshInstance.new()
	mh.mesh = SphereMesh.new()
	mh.set_material_override(mat)
	#  - collision
	var col:CollisionShape = CollisionShape.new()
	col.shape = SphereShape.new()
	#  - rigidbody
	var rb:RigidBody = RigidBody.new()
	rb.name = name
	rb.set_gravity_scale(0)
	rb.set_collision_layer_bit(0,true)
	rb.set_collision_mask_bit(0,true)
	rb.contacts_reported = 1
	rb.contact_monitor = true
	
	rb.add_child(mh)
	rb.add_child(col)
	
	return rb

func clone_rigid_body_agent(var rb0:RigidBody) -> RigidBody:
	return rb0.duplicate() as RigidBody 	# warning : parameters are not cloned (same ref)
										# it's ok now, but could be wrong for some param
	
# Add entity PopUp Menu -----------------------------
func _on_ToolPlusAgent_pressed() -> void:
	var name:String = key_name_create("Agent-")
	addAgent(name)


# Remove entity -----------------------------
func _on_BtnDelAgent_pressed() -> void:
	var lst:ItemList = _listAgents
	var sel:PoolIntArray = lst.get_selected_items()
	if sel.size() > 0:
		lst.remove_item(sel[0])

# TREE of entities -----------------------------
var _selected_name:String = ""
func _on_ListAgents_item_selected(index: int) -> void:
	var sel:PoolIntArray = _listAgents.get_selected_items()
	if sel.size() > 0:
		#_listAgents.remove_item(sel[0])
		var entity_name:String = _listAgents.get_item_text(sel[0])
		var entity:Node = get_entity_from_GUI(entity_name)
		var tabs:TabContainer = get_node("%TabContainer")
		if entity is RigidBody:
			tabs.current_tab = Prop.ENTITY
			_fill_properties_of_agent(entity)
			_selected_name = entity_name
		else:
			tabs = get_node("%TabContainer")	
			if entity is Node:
				tabs.current_tab = Prop.EMPTY
			
func get_entity_from_GUI(var name:String) -> Node:
	var node_entities:Node = get_node("%Entities")
	return node_entities.find_node(name) as Node

# Agent => Properties ----------------------------
func _fill_properties_of_agent(var entity:Node):
	if entity is RigidBody:
		# name
		var box_name:LineEdit = get_node("%AgentName")
		box_name.text = entity.name
		# color
		var box_color:ColorPickerButton = get_node("%ColorAgent")
		var mesh:MeshInstance = entity.get_child(0)
		box_color.color = mesh.material_override.albedo_color
		# type
		var opt_type:OptionButton = get_node("%OptionAgentType")
		opt_type.select(0)
		
# Properties => Agent -----------------------------
# Agent Color
func _on_ColorAgent_color_changed(color: Color) -> void:
	var rb:RigidBody = find_node(_selected_name)
	var msh:MeshInstance = rb.get_child(0)
	var mat:SpatialMaterial = msh.material_override
	mat.albedo_color = color
# Agent Name
func _on_AgentName_focus_exited() -> void:
	var line_edit:LineEdit = get_node("%AgentName")
	var new_name:String = line_edit.text
	if new_name == _selected_name:
		return
	if key_name_exists(new_name) == false: # The new name doesn't exists => can be applied
		_listAgents.get_selected().set_text(0, new_name) # change in 2D tree
		var rb:RigidBody = find_node(_selected_name) # change in ENV
		rb.name = new_name
		_selected_name = new_name
	else: # the new name EXISTS => cannot be changed
		OS.alert("Ce nom est deja attribue", "Information")
		line_edit.text = _selected_name
		
func _on_AgentName_text_entered(new_text: String) -> void:
	_on_AgentName_focus_exited()

		
# ENVIRONMENT  -----------------------------
func _on_ViewportContainer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if _selected_name == "":
					return
				# Position of the mouse click
				var camera = get_node("%Camera")
				var from = camera.project_ray_origin(event.position)
				var to = camera.project_ray_normal(event.position) * 100
				var cursorPos = Plane(Vector3.UP, 0).intersects_ray(from, to)
				#print(cursorPos)
				# Spawn the new entity
				var n_entities:Node = get_node("%Environment")
				var rb:RigidBody = find_node(_selected_name)
				var entity:RigidBody  = clone_rigid_body_agent(rb) #load("res://addons/NetBioDyn-2/3-Agents/Agent-Blue.tscn").instance()
				entity.set_gravity_scale(0)
				n_entities.add_child(entity)
				entity.global_transform.origin = cursorPos  #Vector3(event.position.x-50,0,event.position.y-10)/10 #Vector3(get_parent().get_mouse_position().x,0,get_parent().get_mouse_position().y)/10
				# to be saved as scene, the owner is the simulation "root" node
				#   - see https://godotengine.org/qa/903/how-to-save-a-scene-at-run-time
				#   - see https://github.com/godotengine/godot-proposals/issues/390
				entity.set_owner(get_node("%Simulator"))
				pass


# Behaviors
# *********
func _on_BtnAddBehav_pressed() -> void:
	var lst:ItemList = get_node("%ListBehav")
	lst.add_item("Comportement")
	lst.set_item_metadata(lst.get_item_count()-1, "Reaction") # type of the item

func _on_BtnDelBehav_pressed() -> void:
	var lst:ItemList = get_node("%ListBehav")
	var sel:PoolIntArray = lst.get_selected_items()
	if sel.size() > 0:
		lst.remove_item(sel[0])

func _on_ListBehav_item_selected(index: int) -> void:
	var tabs:TabContainer = get_node("%TabContainer")
	tabs.current_tab = Prop.BEHAVIOR
		
# Groups
# *********
func _on_BtnAddGp_pressed() -> void:
	var lst:ItemList = get_node("%ListGp")
	lst.add_item("Groupe")
	lst.set_item_metadata(lst.get_item_count()-1, "Reaction") # type of the item

func _on_BtnDelGp_pressed() -> void:
	var lst:ItemList = get_node("%ListGp")
	var sel:PoolIntArray = lst.get_selected_items()
	if sel.size() > 0:
		lst.remove_item(sel[0])

# Grids
# *********
func _on_BtnAddGrid_pressed() -> void:
	var lst:ItemList = get_node("%ListGrids")
	lst.add_item("Grille")
	lst.set_item_metadata(lst.get_item_count()-1, "Reaction") # type of the item

func _on_BtnDelGrid_pressed() -> void:
	var lst:ItemList = get_node("%ListGrids")
	var sel:PoolIntArray = lst.get_selected_items()
	if sel.size() > 0:
		lst.remove_item(sel[0])

func _on_ListGrids_item_selected(index: int) -> void:
	var tabs:TabContainer = get_node("%TabContainer")
	tabs.current_tab = Prop.GRID
	
# Env
# *********
func _on_Button_pressed() -> void:
	var tabs:TabContainer = get_node("%TabContainer")
	tabs.current_tab = Prop.ENV

# Window / App control
func _on_BtnClose_pressed():
	get_tree().quit()

# Utilities
func key_name_create(var prefix:String) -> String:
	var simu:Node = get_node("%Simulator")
	for n in 999999:
		var key_name:String = prefix + String(n)
		var node:Node = find_node(key_name)
		if node == null:
			return key_name
	return ""
	
func key_name_exists(var key_name:String) -> bool:
		var node:Node = find_node(key_name)
		if node == null:
			return false
		else:
			return true

