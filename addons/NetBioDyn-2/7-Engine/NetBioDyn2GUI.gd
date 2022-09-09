# **********************************************************
# NetBioDyn 2
# Pascal BALLET
# pascal.ballet@univ-brest.fr
# University of Brest
# MIT Licence
# **********************************************************

# MVC
# This class is the Controler
# The View is scene called ScBioDyn2.tscn
# The Model is the 3D scene

extends Node

# Param Tabs N°
enum Prop {EMPTY, ENTITY, BEHAVIOR_REACTION, BEHAVIOR_RANDOM_FORCE, GRID, ENV, GROUP }

# **********************************************************
#                        KEY NODES                         *
# **********************************************************
# 2D important nodes
var _listAgents:ItemList
var _listBehavs:ItemList
var _node_status	:Label
# 3D simulator nodes
var _node_viewport	:Node
var _node_simu		:Node
var _node_camera	:Node
var _node_entities	:Node
var _node_behavs	:Node
var _node_env		:Node
var _node_groups	:Node

# Simulator time steps
var _step:int = 0
# Env sizes
var _env_min_x:float = -40
var _env_min_y:float =  0
var _env_min_z:float = -40
var _env_max_x:float =  40
var _env_max_y:float =  0
var _env_max_z:float =  40
# instances size
var MAX_AGENTS:int = 2000

# Called when the node enters the scene tree for the first time.
func my_init() -> void:
	# 2D important nodes
	_listAgents 		= find_node("ListAgents")
	_listBehavs 		= find_node("ListBehav")
	_node_status	 	= find_node("LabelStatusbar")
	# 3D simulator nodes
	var tree:SceneTree	= get_tree()
	var scene:Node		= tree.get_current_scene()
	_node_simu	 		= scene.find_node("Simulator") #get_node_recursive(get_tree().get_current_scene(), "Simulator") #get_node("/root/VBoxFrame/HBoxWindows/HSplitContainer/HSplitContainer2/VSplitContainer/VBoxEnvGraph/ViewportContainer")
	if _node_simu == null:
		return
	_node_viewport		= _node_simu.get_parent()
	_node_camera	 	= get_node_direct(_node_simu, "Camera")
	_node_entities 		= get_node_direct(_node_simu, "Entities")
	_node_behavs	 	= get_node_direct(_node_simu, "Behaviors")
	_node_env	 		= get_node_direct(_node_simu, "Environment")
	_node_groups		= get_node_direct(_node_simu, "Groups")

	#get_viewport().connect("gui_focus_changed", self, "set_popup_btn")



#███████  ██████ ██   ██ ███████ ██████  ██    ██ ██      ███████ ██████  
#██      ██      ██   ██ ██      ██   ██ ██    ██ ██      ██      ██   ██ 
#███████ ██      ███████ █████   ██   ██ ██    ██ ██      █████   ██████  
#     ██ ██      ██   ██ ██      ██   ██ ██    ██ ██      ██      ██   ██ 
#███████  ██████ ██   ██ ███████ ██████   ██████  ███████ ███████ ██   ██ 
																		 
																		



# **********************************************************
#                        SCHEDULER                         *
# **********************************************************
func _process(delta):
	# MANAGE Simulator Control (PLAY / STEP / PAUSE / STOP)
	if _sim_play == false:
		if _node_simu == null:
			my_init()
		return
		
	if _sim_play == true && _sim_pause == true && _sim_play_once == false:
		return
		
	if _sim_play_once == true:
		_sim_play_once = false
		
	# PLAY ONE step
	if _step % 100 == 0:
		updateStatus()
		
	if _step % 10 == 0:
		manage_graph()

	# Play Behaviors
	for behav in _node_behavs.get_children():
		for agent in _node_env.get_children():
			behav.action(self, agent) # on applique le comportement behav sur l'agent agt
			#print("test")

	# Environment constraints
	# Torus
	for agent in _node_env.get_children():
		if agent.global_transform.origin.x < _env_min_x:
			agent.global_transform.origin.x = _env_max_x
		if agent.global_transform.origin.y < _env_min_y:
			agent.global_transform.origin.y = _env_max_y
		if agent.global_transform.origin.z < _env_min_z:
			agent.global_transform.origin.z = _env_max_z
		if agent.global_transform.origin.x > _env_max_x:
			agent.global_transform.origin.x = _env_min_x
		if agent.global_transform.origin.y > _env_max_y:
			agent.global_transform.origin.y = _env_min_y
		if agent.global_transform.origin.z > _env_max_z:
			agent.global_transform.origin.z = _env_min_z
			
	# Next simulation step
	_step = _step + 1

func updateStatus()->void:
	var nb_agents:int = _node_env.get_child_count()
	var nb_behavs:int = _node_behavs.get_child_count()
	_node_status.text = str("step=", _step, " | Nb agents=", nb_agents, " | Nb behaviors=", nb_behavs)





# █████   ██████  ████████ ███████            ██████  ██████   ██████  ██████  
#██   ██ ██          ██    ██          ██     ██   ██ ██   ██ ██    ██ ██   ██ 
#███████ ██   ███    ██    ███████            ██████  ██████  ██    ██ ██████  
#██   ██ ██    ██    ██         ██     ██     ██      ██   ██ ██    ██ ██      
#██   ██  ██████     ██    ███████            ██      ██   ██  ██████  ██      




# **********************************************************
#               AGENTS : simple Properties                 *
# **********************************************************

func addAgent(var name:String) -> void:	
	# Create new Agent in GUI -----------------------------
	_listAgents.add_item(name)
	var i:int = _listAgents.get_item_count()-1
	_listAgents.set_item_metadata(i, "Agent") # type of the item
	# Create new Agent Type in 3D Scene -----------------------------
	#print_debug("addAgent")
	var rb:RigidBody = create_rigid_body_agent(name)
	rb.visible = false

	#  - add the Agent to the scene
	_node_entities.add_child(rb)
	print(str("name=", name))
	rb.set_meta("Name", name)
	#rb.set_owner(get_node(_node_simu)
	print(str("**** Exit : AddAgent"))
	#_debug_display_all_meta()
	# Select the added agent
	_listAgents.select(_listAgents.get_item_count()-1)
	_on_ListAgents_item_selected(i)
	
func create_rigid_body_agent(var name:String) -> RigidBody:
	#  - material
	var mat:SpatialMaterial = SpatialMaterial.new()
	mat.albedo_color = Color(randf(),randf(),randf(), 1.0)
	#  - mesh
	var mh:MeshInstance = MeshInstance.new()
	mh.mesh = SphereMesh.new()
	mh.scale = Vector3(1.3, 1.3, 1.3)
	mh.set_material_override(mat)
	#  - collision
	var col:CollisionShape = CollisionShape.new()
	col.shape = SphereShape.new()
	#  - rigidbody
	var rb:RigidBody = RigidBody.new()
	rb.name = name
	rb.set_gravity_scale(0)
	rb.contacts_reported = 1
	rb.contact_monitor = true
	rb.set_linear_damp(5.0)
	rb.translate(Vector3(-999,0,0))
	rb.add_child(mh)
	rb.add_child(col)
	
	return rb

func clone_rigid_body_agent(var rb0:RigidBody) -> RigidBody:
	#print_debug(str(" TRY TO clone_rigid_body_agent " ))
	var rb:RigidBody = rb0.duplicate()
	#print_debug(str(" SUCCESS " ))
	return rb 	# warning : are parameters not cloned ? (but ref only ?)
				# it's ok now, but could be wrong for some param by ref
	
# Add Agent -----------------------------
func _on_ToolPlusAgent_pressed() -> void:
	var name:String = key_name_create()
	#_selected_name = name
	addAgent(name)

# Remove Agent -----------------------------
func _on_BtnDelAgent_pressed() -> void:
	var lst:ItemList = _listAgents
	var sel:PoolIntArray = lst.get_selected_items()
	if sel.size() > 0:
		var agent_name:String = _listAgents.get_item_text(sel[0])
		# Remove all Instances
		for i in _node_env.get_children():
			if i.get_meta("Name") == agent_name:
				i.queue_free()
		# Remove Agent in Entities node
		get_entity(agent_name).queue_free()
		# Remove Agent in 2D List
		lst.remove_item(sel[0])

# List of entities -----------------------------
var _selected_name:String = ""
func _on_ListAgents_item_selected(index: int) -> void:
	var sel:PoolIntArray = _listAgents.get_selected_items()
	if sel.size() > 0:
		#_listAgents.remove_item(sel[0])
		var entity_name:String = _listAgents.get_item_text(sel[0])
		var entity:Node = get_entity(entity_name)
		var tabs:TabContainer = get_node("%TabContainer")
		if entity is RigidBody:
			tabs.current_tab = Prop.ENTITY
			_selected_name = entity_name
			print(str("\nSelect:",_selected_name))
			_fill_properties_of_agent(entity)
		else:
			tabs = get_node("%TabContainer")	
			if entity is Node:
				tabs.current_tab = Prop.EMPTY
			
func get_entity(var name:String) -> Node:
	var i:int = 0
	for e in _node_entities.get_children():
		if e.name == name:
			return _node_entities.get_child(i)
		i = i + 1
	return null

# Agent => Properties ----------------------------
func _fill_properties_of_agent(var agt_type:Node):
	if agt_type is RigidBody:
		# name
		var box_name:LineEdit = get_node("%AgentName")
		box_name.text = agt_type.name
		# color
		var box_color:ColorPickerButton = get_node("%ColorAgent")
		var mesh:MeshInstance = agt_type.get_child(0)
		box_color.color = mesh.material_override.albedo_color
		# type
		var opt_type:OptionButton = get_node("%OptionAgentType")
		opt_type.select(0)
		# Lock axis
		get_node("%CheckX").pressed = agt_type.axis_lock_linear_x
		get_node("%CheckY").pressed = agt_type.axis_lock_linear_y
		get_node("%CheckZ").pressed = agt_type.axis_lock_linear_z
		# groups
		agent_group_to_GUI_group()
		# param
		agent_META_to_GUI() # TODO rename into agent_meta_to_GUI_param
		
# Properties => Agent -----------------------------
# Agent COLOR
func change_agent_color(rb:RigidBody, color:Color)->void:
	if rb==null:
		return
	var msh:MeshInstance = rb.get_child(0)
	var mat:SpatialMaterial = msh.material_override
	mat.albedo_color = color
	
func _on_ColorAgent_color_changed(color: Color) -> void:
	var rb:RigidBody = get_entity(_selected_name)
	if(rb != null):
		change_agent_color(rb, color)
	update_agent_instances(rb)

# Agent NAME
func _on_AgentName_focus_exited() -> void:
	var line_edit:LineEdit = get_node("%AgentName")
	var new_name:String = line_edit.text
	if new_name == _selected_name:
		return
	if get_entity(new_name) == null: # The new name doesn't exists => can be applied
		var sel:PoolIntArray = _listAgents.get_selected_items()
		if sel.size() == 0:
			return
		var pos = sel[0] # pos of agent in list
		_listAgents.set_item_text(pos, new_name) # set new name
		# 3D ENV	
		# Agent prototype
		var rb:RigidBody = get_entity(_selected_name) # change in ENV
		rb.name = new_name
		rb.set_meta("Name", new_name)
		# Agent instances
		for agt in _node_env.get_children():
			if agt.get_meta("Name") == _selected_name:
				agt.set_meta("Name", new_name)
		_selected_name = new_name
	else: # the new name EXISTS => cannot be changed
		#OS.alert("Ce nom est déjà attribué", "Information")
		line_edit.text = _selected_name

func update_agent_axes_lock():
	var rb:RigidBody = get_entity(_selected_name)
	if rb == null:
		return
	var lockX:bool = get_node("%CheckX").is_pressed()
	var lockY:bool = get_node("%CheckY").is_pressed()
	var lockZ:bool = get_node("%CheckZ").is_pressed()
	rb.axis_lock_linear_x = lockX
	rb.axis_lock_linear_y = lockY
	rb.axis_lock_linear_z = lockZ
	update_agent_layer_mask(rb)
	update_agent_instances(rb)

func update_agent_layer_mask(agt:RigidBody)->void:
	if agt.axis_lock_linear_x && agt.axis_lock_linear_z: # Fixed agent => is in layer 1. Only interact with mobile agents (layer 0)
		agt.set_collision_layer_bit(0,false)
		agt.set_collision_layer_bit(1,true)
		agt.set_collision_mask_bit(0,true)
		agt.set_collision_mask_bit(1,false)
	else: # Mobile agent => is in layer 0. Interact with other mobiles (0) AND fixed (1)
		agt.set_collision_layer_bit(0,true)
		agt.set_collision_layer_bit(1,false)
		agt.set_collision_mask_bit(0,true)
		agt.set_collision_mask_bit(1,true)

func update_agent_instances(var rb:RigidBody)->void:
	# Agent instances
	for agt in _node_env.get_children():
		if agt.get_meta("Name") == _selected_name:
			# update color (already made because color is a ref)
			#var msh:MeshInstance = rb.get_child(0)
			#var mat:SpatialMaterial = msh.material_override
			#var color:Color = mat.albedo_color
			#change_agent_color(agt, color)
			
			# update lock x,y,z
			agt.axis_lock_linear_x = rb.axis_lock_linear_x
			agt.axis_lock_linear_y = rb.axis_lock_linear_y
			agt.axis_lock_linear_z = rb.axis_lock_linear_z
			update_agent_layer_mask(agt)
			# update groups **********************
			# Clear Group of agt
			var lst_gp_agt = agt.get_groups()
			for gp in lst_gp_agt:
				agt.remove_from_group(gp)
			# Put groups of rb to agt
			var lst_gp_rb = rb.get_groups()
			for gp in lst_gp_rb:
				agt.add_to_group(gp, true)

			# update Param ************************
			#(TODO + if ref => make param copies when instancing)

func _on_AgentName_text_entered(new_text: String) -> void:
	_on_AgentName_focus_exited()




#█████   ██████  ████████ ███████             ██████  ██████  
#██   ██ ██          ██    ██          ██     ██       ██   ██ 
#███████ ██   ███    ██    ███████            ██   ███ ██████  
#██   ██ ██    ██    ██         ██     ██     ██    ██ ██      
#██   ██  ██████     ██    ███████             ██████  ██




# **********************************************************
#                     AGENTS : Groups                      *
# **********************************************************
# Thanks to: http://patorjk.com/software/taag/#p=display&f=ANSI%20Regular&t=AGTS%20%3A%20GP
func _on_ButtonAddGroup() -> void:
	# Crete a unique name for the parameter (Meta names are key of dictionnary)
	# Create the line of input boxes
	var vbox_group:	VBoxContainer = get_node("%VBoxAgentGroup")
	var hbox_line :	HBoxContainer = get_node("%HBoxLineGroup")
	var new_line: 	HBoxContainer = hbox_line.duplicate()
	new_line.visible = true
	vbox_group.add_child(new_line)
	# Save to groups
	#agent_GUI_groups_to_groups()

# GUI GROUPS => GROUPS
func agent_GUI_groups_to_groups(new_group: String="") -> void:
	var rb:RigidBody = get_entity(_selected_name)
	if rb==null:
		return
	# Remove from all Groups
	var lst_gp = rb.get_groups()
	for gp in lst_gp:
		rb.remove_from_group(gp)
	var vbox_group:	VBoxContainer = get_node("%VBoxAgentGroup")
	# Re-Fill Groups
	for i in vbox_group.get_child_count():
		var line:HBoxContainer = vbox_group.get_child(i)
		var group_name :String  	= line.get_child(1).get_text()
		rb.add_to_group(group_name,true)
	update_agent_instances(rb)

# GROUP => GUI GROUP
func agent_group_to_GUI_group() -> void:
	#printerr(str("meta => PARAM for ", _selected_name))
	var rb:RigidBody = get_entity(_selected_name)
	if rb==null:
		return
	var vbox_group:	VBoxContainer = get_node("%VBoxAgentGroup")
	# Clear Group VBox (Contains all the Lines where Groups are displayed)
	for i in vbox_group.get_child_count():
		var line:HBoxContainer = vbox_group.get_child(0)
		vbox_group.remove_child(line)
		line.queue_free()
	# Re-Fill Group VBox with all the Lines displaying Groups
	for gp in rb.get_groups():
		#var group_name :String = rb.get_groups()[m]
		_on_ButtonAddGroup() # Add the Line widgets
		var line:HBoxContainer = vbox_group.get_child(vbox_group.get_child_count()-1)
		line.get_child(1).set_text(gp) #group_name) # Display the group name in the LineEdit widget

# Remove group
func _on_button_del_group_of_agent() -> void:
	var vbox_group:	VBoxContainer = get_node("%VBoxAgentGroup")
	for i in vbox_group.get_child_count():
		var line:HBoxContainer = vbox_group.get_child(i)
		var btn_del:Button = line.get_child(2)
		if btn_del.has_focus():
			vbox_group.remove_child(line)
			break
	# Save to groups (remove all groups then re-fill them (except the deleted one))
	agent_GUI_groups_to_groups()




# █████   ██████  ████████ ███████            ███    ███ ███████ ████████  █████  
#██   ██ ██          ██    ██          ██     ████  ████ ██         ██    ██   ██ 
#███████ ██   ███    ██    ███████            ██ ████ ██ █████      ██    ███████ 
#██   ██ ██    ██    ██         ██     ██     ██  ██  ██ ██         ██    ██   ██ 
#██   ██  ██████     ██    ███████            ██      ██ ███████    ██    ██   ██ 
																				




# **********************************************************
#             AGENTS : Parameters (METADATA)               *
# **********************************************************

func _on_ButtonAddParam_button_down() -> void:
	#print(str("\nAdd GUI Param"))
	# Crete a unique name for the parameter (Meta names are key of dictionnary)
	var key_param:String  = key_param_create()
	# Create the line of input boxes
	var vbox_param:	VBoxContainer = get_node("%VBoxAgentParam")
	var hbox_line :	HBoxContainer = get_node("%HBoxLineParam")
	var new_line: 	HBoxContainer = hbox_line.duplicate()
	new_line.get_child(0).set_text(key_param)
	new_line.visible = true
	vbox_param.add_child(new_line)
	# Save to meta
	agent_GUI_to_META()
	#_debug_display_all_meta()
	#print(str("Exit Add GUI Param\n"))

func add_param_line() -> void:
	# Create the line of input boxes
	var vbox_param:	VBoxContainer = get_node("%VBoxAgentParam")
	var hbox_line :	HBoxContainer = get_node("%HBoxLineParam")
	var new_line: 	HBoxContainer = hbox_line.duplicate()
	new_line.visible = true
	vbox_param.add_child(new_line)

# Remove param (TODO : change function name to : _on_button_del_param_of_agent)
func _on_Button_button_down() -> void:
	var vbox_param:	VBoxContainer = get_node("%VBoxAgentParam")
	for i in vbox_param.get_child_count():
		var line:HBoxContainer = vbox_param.get_child(i)
		var btn_del:Button = line.get_child(3)
		if btn_del.has_focus():
			vbox_param.remove_child(line)
			break
	# Save to meta (new_name VALIDATED)
	agent_GUI_to_META()
	
# META => GUI PARAM
func agent_META_to_GUI() -> void:
	#printerr(str("** Enter : META=>GUI"))
	#_debug_display_all_meta()

	#printerr(str("meta => PARAM for ", _selected_name))
	var rb:RigidBody = get_entity(_selected_name)
	if rb==null:
		return
	var vbox_param:	VBoxContainer = get_node("%VBoxAgentParam")
	# Clear Param VBox
	#print(str("CLEAR PARAM VBOX"))
	#_debug_display_all_meta()
	for i in vbox_param.get_child_count():
		var line:HBoxContainer = vbox_param.get_child(0)
		vbox_param.remove_child(line)
		line.queue_free()
	# Fill Param VBox
	#print(str("FILL PARAM VBOX"))
	#_debug_display_all_meta()
	var lst:PoolStringArray = rb.get_meta_list()
	var nb_param:int = lst.size()
	#print(str("lst = ", lst))
	for m in nb_param:
		var meta_name :String  	= lst[m]# rb.get_meta_list()[m]
		var meta_value			= rb.get_meta(meta_name)
		#print(str("  - ", _selected_name , " : META=>GUI ", meta_name , " = " , meta_value))
		if meta_name != "Name":
			add_param_line()
			var nb_children:int 	= vbox_param.get_child_count()
			var line:HBoxContainer 	= vbox_param.get_child(nb_children-1)
			line.get_child(0).set_text(meta_name)
			line.get_child(2).set_text(meta_value)
	#printerr(str("***    Exit : META=>GUI" ))
	#_debug_display_all_meta()


# GUI => META
func agent_GUI_to_META() -> void:
	#printerr(str("*** Enter : GUI => META for ", _selected_name))
	#_debug_display_all_meta()
	
	var rb:RigidBody = get_entity(_selected_name)
	if rb==null:
		return
	# Clear Meta
	for meta_name in rb.get_meta_list():
		#print(str("remove:",meta_name,"=",rb.get_meta(meta_name)))
		rb.remove_meta(meta_name)
		
	#######################
	#print(str("a) nb meta=",rb.get_meta_list().size()))
		
	rb.set_meta("Name", rb.name)
	var vbox_param:	VBoxContainer = get_node("%VBoxAgentParam")
	# Fill Meta
	for i in vbox_param.get_child_count():
		var line:HBoxContainer = vbox_param.get_child(i)
		var param_name :String  = line.get_child(0).get_text()
		var param_value			= line.get_child(2).get_text()
		#print(str(_selected_name , " GUI=>META: ", param_name , " = " , param_value))
		#print(str(">>>>>> add meta:",param_name,"=",param_value))
		rb.set_meta(param_name, param_value)
	#print(str("b) nb meta=",rb.get_meta_list().size()))
	#######################
	#printerr(str("***       : Before update instances" ))
	#_debug_display_all_meta()
	update_agent_instances(rb)
	#printerr(str("***       : After update instances" ))
	#_debug_display_all_meta()

# get the line number of agent param having possibly the focus
var _selected_param_pos:int = -1
var _selected_param_name:String = ""

func get_param_line_has_focus() -> int :
	var vbox_param:	VBoxContainer = get_node("%VBoxAgentParam")
	for i in vbox_param.get_child_count():
		var line:HBoxContainer = vbox_param.get_child(i)
		var param_edit:LineEdit = line.get_child(0)
		var value_edit:LineEdit = line.get_child(2)
		var btn_del:Button = line.get_child(3)
		if param_edit.has_focus() or value_edit.has_focus() or btn_del.has_focus():
			return i
	return -1

func _on_ParamName_focus_exited() -> void:
	#print(str("** Enter : Param Focus Lost"))
	# Verif Name if unique
	var vbox_param:	VBoxContainer = get_node("%VBoxAgentParam")
	var i:int = _selected_param_pos
	#print(str("   _selected_param_pos = ", i))
	var line:HBoxContainer = vbox_param.get_child(i)
	var old_name:String = _selected_param_name
	var new_name:String = line.get_child(0).get_text()
	if old_name==new_name: # Name NOT changed
		return
	if key_param_exists(new_name) == 2: # Name already EXISTS
		OS.alert("Ce nom est déjà attribué", "Information")
		line.get_child(0).set_text(old_name)
		return
	# Save to meta (new_name VALIDATED)
	agent_GUI_to_META()

# agent param
func _on_ParamValue_focus_exited() -> void:
	# Save to meta
	agent_GUI_to_META()

func _on_ParamName_focus_entered() -> void:
	_selected_param_pos = get_param_line_has_focus()
	var vbox_param:	VBoxContainer = get_node("%VBoxAgentParam")
	var line:HBoxContainer = vbox_param.get_child(_selected_param_pos)
	_selected_param_name = line.get_child(0).get_text()

func _on_ParamName_text_entered(new_text: String) -> void:
	_on_ParamName_focus_exited()


func _debug_display_meta(rb:RigidBody) -> void:
	printerr(str("*** Enter : DISPLAY META for : ", rb.name))
	if rb==null:
		return
	# Display Meta
	for meta_name in rb.get_meta_list():
		print(str("    Meta : ",meta_name," = ",rb.get_meta(meta_name)))

func _debug_display_all_meta() -> void:
	for rb in _node_entities.get_children():
		_debug_display_meta(rb)




#███████ ███    ██ ██    ██ 
#██      ████   ██ ██    ██ 
#█████   ██ ██  ██ ██    ██ 
#██      ██  ██ ██  ██  ██  
#███████ ██   ████   ████   



# ************************************************************
#                          ENVIRONMENT                       *
# ************************************************************

enum _draw {POINT, SPRAY, LINE, ERASER, CLEAR }
var _prev_cursor_agent_pos = Vector3(_env_min_x - 1000 , 0 , _env_min_z - 1000)
var _mouse_btn_down:bool = false

# Show relevant property TAB ------------------------------
func _on_Button_pressed() -> void:
	var tabs:TabContainer = get_node("%TabContainer")
	tabs.current_tab = Prop.ENV

# On Mouse Click -----------------------------
func _on_ViewportContainer_gui_input(event: InputEvent) -> void:
		
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				_mouse_btn_down = true
			else:
				_mouse_btn_down = false
	
	# The use clic in the Env	
	if _mouse_btn_down == true:
		# Spawn a new Agent
		if get_node("%CmbEnvDraw").selected == _draw.POINT:
			if _selected_name == "":
				return
			# Is the Env clear to put a new agent?
			var selection:Dictionary = get_object_under_mouse(event.position)
			if selection.size() > 0:
				return # Not clear => impossible to spawn an agent
			# Position of the mouse click in 3D Env
			var cursorPos:Vector3 = get_env_coordinate_from_mouse_position(event.position)
			# Spawn a new agent at the cursor position
			spawn_agent(self, _selected_name, cursorPos)
			updateStatus()
			return
		# Delete an Agent Instance
		if get_node("%CmbEnvDraw").selected == _draw.ERASER:
			# Find the selected agent instance
			var selection:Dictionary = get_object_under_mouse(event.position)
			if selection.size() == 0:
				return # No agent instance to delete
			else:
				var vals:Array = selection.values()
				vals[3].queue_free()
				updateStatus()
				return			
	
# Get the 3D pos in Env of the mouse cursor			
func get_env_coordinate_from_mouse_position(mouse_pos:Vector2) -> Vector3:
	var from 		= _node_camera.project_ray_origin(mouse_pos)
	var to 			= _node_camera.project_ray_normal(mouse_pos) * 100
	var cursorPos 	= Plane(Vector3.UP, 0).intersects_ray(from, to)
	return cursorPos

# cast a ray from camera at mouse position, and get the object colliding with the ray
func get_object_under_mouse(mouse_pos:Vector2) -> Dictionary:
	var from 		= _node_camera.project_ray_origin(mouse_pos)
	var cursorPos 	= get_env_coordinate_from_mouse_position(mouse_pos)	
	var space_state = _node_camera.get_world().direct_space_state
	var selection:Dictionary = space_state.intersect_ray(from, cursorPos)
	return selection
	
#	var ray_length:float = 100
#	var mouse_pos = get_viewport().get_mouse_position()
#	var ray_from = _node_camera.project_ray_origin(mouse_pos)
#	var ray_to = ray_from + _node_camera.project_ray_normal(mouse_pos) * ray_length
#	#print(ray_from)
#	#print(ray_to)
#	var space_state = _node_camera.get_world().direct_space_state
#	var selection = space_state.intersect_ray(ray_from, ray_to)
#	return selection
		
func spawn_agent(var tree:Node, var name:String, var pos:Vector3) -> void:
	# Spawn the new entity
	var n_agents:Node 	= tree._node_env #tree.get_node("%Environment")
	var rb:RigidBody 	= tree.get_entity(name)
	var agent:RigidBody = tree.clone_rigid_body_agent(rb)
	# Set instance parameters
	agent.visible = true
	agent.set_gravity_scale(0)
	agent.set_meta("Name", rb.name)
	# Attach the instance to env
	n_agents.add_child(agent)
	agent.global_transform.origin = pos

func _on_ButtonClearEnv_pressed() -> void:
	for rb in _node_env.get_children():
		rb.queue_free()





#██████  ███████ ██   ██  █████  ██    ██ ██  ██████  ██████  ███████ 
#██   ██ ██      ██   ██ ██   ██ ██    ██ ██ ██    ██ ██   ██ ██      
#██████  █████   ███████ ███████ ██    ██ ██ ██    ██ ██████  ███████ 
#██   ██ ██      ██   ██ ██   ██  ██  ██  ██ ██    ██ ██   ██      ██ 
#██████  ███████ ██   ██ ██   ██   ████   ██  ██████  ██   ██ ███████ 
																	 





# ************************************************************
#                          Behaviors                         *
# ************************************************************

var _pm:PopupMenu

# Display the Behaviors PopupMenu
func _on_BtnAddBehav_pressed() -> void:
	_pm = $PopupMenu
	var btn_add = get_node("%BtnAddBehav")
	_pm.popup(Rect2(btn_add.get_global_position().x, btn_add.get_global_position().y, _pm.rect_size.x, _pm.rect_size.y))

# Wait for which Behav is selected
func _on_PopupMenu_index_pressed(index: int) -> void:
	if index == 0: # Create Reaction
		addBehavReaction()
	if index == 1: # Create Random Force
		addBehavRandomForce()

# Add REACTION
func addBehavReaction() -> void:	
	# Create new Behavior in GUI --------------------------------
	_listBehavs.add_item("Reaction")
	_listBehavs.set_item_metadata(_listBehavs.get_item_count()-1, "Reaction") # type of the item
	
	# Create default Behavior Type in 3D Scene -------------------	
	var r1:String = ""
	var r2:String = "0"
	var p:String = "100"
	var p1:String = "0"
	var p2:String = "0"
	var p3:String = "0"
	
		# Set META
	var node:Node = Node.new()
	node.set_meta("Type", "Reaction")
	node.set_meta("Name", "Réaction")
	node.set_meta("R1", r1)
	node.set_meta("R2", r2)
	node.set_meta("p", p)
	node.set_meta("P1", p1)
	node.set_meta("P2", p2)
	node.set_meta("P3", p3)
	
	# Set default Script
	var script:GDScript = GDScript.new()
	script.source_code = behav_script_reaction(r1, r2, p, p1, p2, p3)
	print_debug(script.source_code)
	script.reload()
	node.set_script(script) #load("res://addons/NetBioDyn-2/4-Behaviors/DeathTest.gd"))

	# Add Behavior to Simulator
	_node_behavs.add_child(node)

	# Select the added agent
	_listBehavs.select(_listBehavs.get_item_count()-1)
	_on_ListBehav_item_selected(_listBehavs.get_item_count()-1)

# Add FORCE ALEATOIRE
func addBehavRandomForce() -> void:	
	# Create new Behavior in GUI --------------------------------
	_listBehavs.add_item("Force Aléatoire")
	_listBehavs.set_item_metadata(_listBehavs.get_item_count()-1, "Random Force") # type of the item
	
	# Create default Behavior Type in 3D Scene -------------------	
	var agents:String = ""
	var dir:String = "0"
	var angle:String = "360"
	var intensity:String = "1"
	
		# Set META
	var node:Node = Node.new()
	node.set_meta("Type", "Random Force")
	node.set_meta("Name", "Force aléatoire")
	node.set_meta("Agents", agents)
	node.set_meta("Dir", dir)
	node.set_meta("Angle", angle)
	node.set_meta("Intensity", intensity)
	
	# Set default Script
	var script:GDScript = GDScript.new()
	script.source_code = behav_script_random_force(agents, dir, angle, intensity)
	print_debug(script.source_code)
	script.reload()
	node.set_script(script)

	# Add Behavior to Simulator
	_node_behavs.add_child(node)

# Remove behavior
func _on_BtnDelBehav_pressed() -> void:
	var lst:ItemList = _listBehavs
	var sel:PoolIntArray = lst.get_selected_items()
	if sel.size() > 0:
		get_selected_behavior().queue_free()
		lst.remove_item(sel[0])

# Select behavior : META => GUI
func _on_ListBehav_item_selected(param) -> void:
	var behav:Node = get_selected_behavior()
	var type = behav.get_meta("Type")
	# Find the Behavior Type
	if type == "Reaction":
		var tabs:TabContainer = get_node("%TabContainer")
		tabs.current_tab = Prop.BEHAVIOR_REACTION
		# Update GUI Behavior
		# Reaction: Set behavior Name
		get_node("%ParamBehavName").set_text(behav.get_meta("Name"))
		get_node("%ParamBehavProba").set_text(behav.get_meta("p"))
		# Populate OptionButtons with agents & groups & R1 & R2 & 0
		populate_option_btn_with_agents(get_node("%ParamBehavR1"), behav.get_meta("R1"), true, false, false)
		populate_option_btn_with_agents(get_node("%ParamBehavR2"), behav.get_meta("R2"), true, true, false)
		populate_option_btn_with_agents(get_node("%ParamBehavP1"), behav.get_meta("P1"), true, true, true)
		populate_option_btn_with_agents(get_node("%ParamBehavP2"), behav.get_meta("P2"), true, true, true)
		populate_option_btn_with_agents(get_node("%ParamBehavP3"), behav.get_meta("P3"), true, true, true)

	if type == "Random Force":
		var tabs:TabContainer = get_node("%TabContainer")
		tabs.current_tab = Prop.BEHAVIOR_RANDOM_FORCE
		# Update GUI Behavior
		get_node("%BehavRndFName").set_text(behav.get_meta("Name"))
		get_node("%BehavRndFDir").set_text(behav.get_meta("Dir"))
		get_node("%BehavRndFAngle").set_text(behav.get_meta("Angle"))
		get_node("%BehavRndFIntensity").set_text(behav.get_meta("Intensity"))
		# Populate OptionButton with agents & groups
		populate_option_btn_with_agents(get_node("%BehavRndFAgents"), behav.get_meta("Agents"), true, false, false)


func GUI_param_updated(param=null)->void:
	behavior_GUI_to_META()

# Update behavior : GUI => META
func behavior_GUI_to_META() -> void:
	var sel:PoolIntArray = _listBehavs.get_selected_items()
	if sel.size() == 0:
		return

	var behav:Node = get_selected_behavior()
	var type:String = behav.get_meta("Type")
	# Find the Behavior Type
	if type == "Reaction":
		# Set the Name in the GUI List
		var pos:int =sel[0]
		_listBehavs.set_item_text(pos, get_node("%ParamBehavName").get_text())
		
		# Update behavior GUI => META
		var name:String = get_node("%ParamBehavName").get_text()
		var R1:String = get_node("%ParamBehavR1").get_text()
		var R2:String = get_node("%ParamBehavR2").get_text()
		var proba:String = get_node("%ParamBehavProba").get_text()
		var P1:String = get_node("%ParamBehavP1").get_text()
		var P2:String = get_node("%ParamBehavP2").get_text()
		var P3:String = get_node("%ParamBehavP3").get_text()
		behav.set_meta("Name", name)
		behav.set_meta("R1", R1)
		behav.set_meta("R2", R2)
		behav.set_meta("p", proba)
		behav.set_meta("P1", P1)
		behav.set_meta("P2", P2)
		behav.set_meta("P3", P3)
		
		# Set Script
		var script:GDScript = GDScript.new()
		script.source_code = behav_script_reaction(R1, R2, proba, P1, P2, P3)
		print_debug(script.source_code)
		script.reload()
		behav.set_script(script)

	if type == "Random Force":
		# Set the Name in the GUI List
		var pos:int =sel[0]
		_listBehavs.set_item_text(pos, get_node("%BehavRndFName").get_text())
		
		# Update behavior GUI => META
		var name:String 		= get_node("%BehavRndFName").get_text()
		var agents:String 	= get_node("%BehavRndFAgents").get_text()
		var dir:String 		= get_node("%BehavRndFDir").get_text()
		var angle:String 	= get_node("%BehavRndFAngle").get_text()
		var intensity:String = get_node("%BehavRndFIntensity").get_text()
		behav.set_meta("Name", name)
		behav.set_meta("Agents", agents)
		behav.set_meta("Dir", dir)
		behav.set_meta("Angle", angle)
		behav.set_meta("Intensity", intensity)
		
		# Set Script
		var script:GDScript = GDScript.new()
		script.source_code = behav_script_random_force(agents, dir, angle, intensity)
		print_debug(script.source_code)
		script.reload()
		behav.set_script(script)

	#print_debug(param_name)
	#print_debug(param_value)
	#print_debug(behav)





# ██████  ██████   ██████  ██    ██ ██████  ███████ 
#██       ██   ██ ██    ██ ██    ██ ██   ██ ██      
#██   ███ ██████  ██    ██ ██    ██ ██████  ███████ 
#██    ██ ██   ██ ██    ██ ██    ██ ██           ██ 
# ██████  ██   ██  ██████   ██████  ██      ███████




# ************************************************************
#                           Groups                           *
# ************************************************************

var text_unique:bool = true
var _line_edit_with_pb:LineEdit = null
var _latest_modified_group_line = null
var _good_gp_name:String = ""

func _on_BtnAddGp_pressed() -> void:
	#Add in 2D List
	var vb:VBoxContainer = get_node("%VBoxGp")
	var node_line_gp:Node = get_node("%HBoxLineGp").duplicate(15)
	node_line_gp.visible = true
	vb.add_child(node_line_gp)
	# Add in 3D Simulator
	_node_groups.add_child(Node.new())

func get_selected_group() -> LineEdit:
	var vb:VBoxContainer = get_node("%VBoxGp")
	for i in vb.get_children():
		if i.get_child(0).has_focus() == true || i.get_child(1).has_focus() == true :
			return i.get_child(0)
	return null

func _on_ButtonDelGp_pressed() -> void:
	var gp:Node = get_selected_group()
	if gp != null:
		get_node_direct(_node_groups, gp.text).queue_free()
		gp.get_parent().queue_free()

# Update name of Groups
func update_groups(s:String = "") -> void:
	# Update if doublon in 2D List
	if text_unique == false: # The name has a problem => changedd to the latest non-doublon name
		_line_edit_with_pb.text = _good_gp_name
		text_unique == false

	# Update the name of Group Nodes in Simulator
	var pos = get_index_of_group_line(_good_gp_name) # Get the index in the 2D List
	_node_groups.get_child(pos).name = _good_gp_name

func get_index_of_group_line(name:String) -> int:
	var vb:VBoxContainer = get_node("%VBoxGp")
	var i:int = 0
	var pos:int = -1
	for line in vb.get_children():
		if line.get_child(0).text == _good_gp_name:
			pos = i
		i = i + 1
	return pos

func key_group_count(var key_name:String) -> int:
	var vbox:VBoxContainer = get_node("%VBoxGp")
	var nb_keys:float = vbox.get_child_count()
	var nb:int = 0
	for n in range(0,nb_keys):
		var line:HBoxContainer = vbox.get_child(n)
		var name:String = line.get_child(0).get_text()
		if key_name == name:
			nb = nb+1
	return nb

func _on_GroupValue_changed(var new_text:String) -> void :
	var current_gp:Node = get_selected_group()
	var doublons:int = key_group_count(new_text)
	if doublons >= 2:
		text_unique = false
		_line_edit_with_pb = current_gp
	else:
		text_unique = true
		_good_gp_name = new_text
	_latest_modified_group_line = current_gp

# Groups of Simulator => Groups in 2D List
# Should be only used in Load of a simulation file
func set_group_from_simulator_to_GUI() -> void:
	var vbox:VBoxContainer = get_node("%VBoxGp")
	# Clear the 2D List of Groups
	for line in vbox.get_children():
		line.queue_free()
	# Re Fill the 2D List of Groups from the Simulator
	for gp in _node_groups.get_children():
		var vb:VBoxContainer = get_node("%VBoxGp")
		var node_line_gp:Node = get_node("%HBoxLineGp").duplicate(15)
		node_line_gp.visible = true
		vb.add_child(node_line_gp)
		node_line_gp.get_child(0).text = gp.name







# ██████  ██████  ██ ██████  ███████ 
#██       ██   ██ ██ ██   ██ ██      
#██   ███ ██████  ██ ██   ██ ███████ 
#██    ██ ██   ██ ██ ██   ██      ██ 
# ██████  ██   ██ ██ ██████  ███████





# ************************************************************
#                              Grids                         *
# ************************************************************

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
	
	
	
	

#███████ ██ ███    ███ ██    ██          ██████ ████████ ██████  ██      
#██      ██ ████  ████ ██    ██         ██         ██    ██   ██ ██      
#███████ ██ ██ ████ ██ ██    ██         ██         ██    ██████  ██      
#     ██ ██ ██  ██  ██ ██    ██         ██         ██    ██   ██ ██      
#███████ ██ ██      ██  ██████           ██████    ██    ██   ██ ███████ 
																	   
															 

															 
# ************************************************
# SIMULATOR CONTROLS
# ************************************************

var _sim_play: bool  = false
var _sim_pause:bool  = false
var _sim_play_once: bool  = false

func _on_BtnPlay_pressed() -> void:
	# TODO : Save initial state
	if _sim_play == false:
		save_initial_state()
	_sim_play = true
	_sim_pause = false
	_sim_play_once = false
	
func _on_BtnStep_pressed() -> void:
	_sim_play = true
	_sim_pause = true
	_sim_play_once = true
	
func _on_BtnPause_pressed() -> void:
	if _sim_pause == true:
		_sim_pause = false
	else:
		_sim_pause = true
		
func _on_BtnStop_pressed() -> void:
	# TODO : Reload initial state
	if _sim_play == true:
		load_initial_state()
	_sim_play = false
	_sim_pause = false
	_sim_play_once = false
	_step = 0
	updateStatus()

var _node_simu_init:Spatial
# Save initial state when playing
func save_initial_state() -> void:
	# Duplicate the node (prevents an error)
	_node_simu_init = _node_simu.duplicate(15)

	# Setting simu node as owner of all its
	# children for saving reasons
	#set_owner_recursive(_node_simu_init, _node_simu_init)

# Load initial state when stopping
func load_initial_state() -> void:
	# Load the simulation
	# Remove the current simu
	_node_viewport.remove_child(_node_simu)
	_node_simu.call_deferred("free")

	# Add the next level
	#var next_simu_res = load(filename) #load("res://Simulations/Simu.tscn")
	#if next_simu_res == null:
	#	print(str("Impossible to read file: ", filename))
	#	return
	#var next_simu_node = next_simu_res.instance()
	
	# TO DO : verify the tree structure before loading it (Nodes Simulator, then Entities, Behaviors ,etc)
	
	# The structure is ok => attach it to the Viewport
	_node_viewport.add_child(_node_simu_init)
	
	# re-init 3D node variables
	_node_camera	= _node_simu_init.get_node("Camera")
	_node_simu 		= _node_simu_init
	_node_entities 	= _node_simu_init.get_node("Entities")
	_node_behavs 	= _node_simu_init.get_node("Behaviors")
	_node_env 		= _node_simu_init.get_node("Environment")
	_node_groups	= _node_simu_init.get_node("Groups")



#██    ██ ████████ ██ ██      ██ ████████ ██ ███████ ███████ 
#██    ██    ██    ██ ██      ██    ██    ██ ██      ██      
#██    ██    ██    ██ ██      ██    ██    ██ █████   ███████ 
#██    ██    ██    ██ ██      ██    ██    ██ ██           ██ 
# ██████     ██    ██ ███████ ██    ██    ██ ███████ ███████ 





# ************************************************************
#                           Utilities                        *
# ************************************************************

# Key name Generator --------------------------
func key_name_create() -> String:
	var prefix:String = "Agent-"
	for n in range(1,999999):
		var key_name:String = prefix + String(n)
		var exists:Node = get_node_direct(_node_entities, key_name)
		if exists == null:
			return key_name
	return "FULL"
	
func get_node_direct(var root:Node, var key_name:String) -> Node:
	for nd in root.get_children():
		if nd.name == key_name:
			return nd
	return null

func get_node_recursive(var node:Node, var name:String) -> Node:
	var node_name:String = node.name
	if node_name == name:
		return node
	else:
		for nd in node.get_children():
			get_node_recursive(nd , name)
	return null
	

func key_param_create() -> String:
	var prefix:String = "Param-"
	var vbox:VBoxContainer = get_node("%VBoxAgentParam")
	for n in range(1, 999999):
		var key_name:String = prefix + String(n)
		#printerr(str("Try to create param : ", key_name))
		var exists:int = key_param_exists(key_name)
		if exists == 0:
			return key_name
	return "FULL"

func key_param_exists(var key_name:String) -> int:
	var vbox:VBoxContainer = get_node("%VBoxAgentParam")
	var nb_param:float = vbox.get_child_count()
	#printerr(str("func key_param_exists => ", "nb_param=" , nb_param))
	#printerr(str("range=",range(1,nb_param)))
	var nb:int = 0
	for n in range(0,nb_param):
		#printerr(str("	n=",n))
		var line:HBoxContainer = vbox.get_child(n)
		var name:String = line.get_child(0).get_text()
		#printerr(str("Verify : ", key_name, " with existing :", name))
		if key_name == name:
			nb = nb+1
	return nb

func get_selected_behavior() -> Node:
	var sel:PoolIntArray = _listBehavs.get_selected_items()
	if sel.size() == 0:
		return null
	
	var pos:int =sel[0]
	
	var node:Node = _node_behavs.get_child(pos)
	return node

# Population Option Button
func populate_option_btn_with_agents(opt:OptionButton, selected_name:String, add_groups:bool, add_zero:bool, add_reactives:bool) -> void:
		# Remove all items
		opt.clear()
		opt.add_item(  ""   )
		# Add Agents and eventually Groups
		for i in _listAgents.get_item_count():
			var txt:String = _listAgents.get_item_text(i)
			opt.add_item(  txt   )
			if txt == selected_name:
				opt.selected = i+1
		var j:int = _listAgents.get_item_count()
		if add_groups == true:
			var lst_gp:VBoxContainer = get_node("%VBoxGp")
			for gp in lst_gp.get_children():
				var txt:String = gp.get_child(0).text
				opt.add_item(  txt   )
				if txt == selected_name:
					opt.selected = j+1
				j = j + 1
		if add_reactives == true:
			opt.add_item("R1")
			if "R1" == selected_name:
				opt.selected = j+1
			j = j + 1
			opt.add_item("R2")
			if "R2" == selected_name:
				opt.selected = j+1
			j = j + 1
		if add_zero == true:
			opt.add_item("0")
			if "0" == selected_name:
				opt.selected = j+1

		# Set the selected agent / group
		opt.set_text(selected_name)


# Window / App control -------------------------
func _on_BtnClose_pressed():
	get_tree().quit()





#███████  ██████ ██████  ██ ██████  ████████ ███████ 
#██      ██      ██   ██ ██ ██   ██    ██    ██      
#███████ ██      ██████  ██ ██████     ██    ███████ 
#     ██ ██      ██   ██ ██ ██         ██         ██ 
#███████  ██████ ██   ██ ██ ██         ██    ███████ 





# ************************************************************
#                     SCRIPTS for Behaviors                  *
# ************************************************************

func in_quote(var s:String)->String:
	return "\""+s+"\""

# Script DEFAULT
func behav_script_default() -> String:
	return """
extends Node
# Default Behavior
func action(tree, agent) -> void:
	pass
"""

# Script RANDOM FORCE
func behav_script_random_force(agents:String, dir:String, angle:String, intensity:String) -> String:
	angle = String(float(angle) * 6.28318530718 / 360.0) # deg to rad
	dir = String(float(dir) * 6.28318530718 / 360.0)	# deg to rad
	var intens = randf() * float(intensity) # The intensity is in [0, intensity]
	print(intens)
	intensity = String(intens)
	return """
extends Node
# Default Behavior
func action(tree, agent) -> void:
	if agent.get_meta("Name") == """+in_quote(agents)+""" || agent.is_in_group("""+in_quote(agents)+"""):
		var alpha:float = randf() * """+angle+""" - """ +angle+ """ /2.0
		agent.apply_impulse(Vector3(0,0,0), Vector3("""+intensity+""" * cos(alpha+"""+dir+"""),0, """+intensity+"""*sin(alpha+"""+dir+""")))
"""

# Script REACTION
func behav_script_reaction(r1:String, r2:String, p:String, p1:String, p2:String, p3:String) -> String:
	return """
extends Node

# Reaction
func action(tree, R1) -> void:
	var proba:float = """+p+"""
	var alea:float = rand_range(0,100)
	#print_debug(str("alea=", alea, ", proba=", proba))
	if alea < proba:
		#print (str("proba ok:",proba))
		if R1.is_queued_for_deletion() == false && (R1.get_meta("Name") == """+in_quote(r1)+""" || R1.is_in_group("""+in_quote(r1)+""")   ): # R1 n'est pas déjà détruit et il appartient au bon groupe:
			#var R1:Spatial 		= collision[0]
			var nb_agents:int 	= R1.get_parent().get_child_count()
			#print ("nb=", nb_agents)
			#print("R1 is in gp : ", inputs[2])
			# Cas avec R2 == 0 ########################################################################################
			if """+in_quote(r2)+""" == "0": # Pas de 2nd réactif => toujours appliqué (à la proba précédente près)
				# si R1 CHANGE en P1 (il n'est ni enlevé, ni prolongé, il est donc remplacé par P1)
				if """+in_quote(p1)+""" != "0" && """+in_quote(p1)+""" != "R1" && """+in_quote(p1)+""" != "R2":
					#var P1 = null # et P1 peut être soit un nouvel agent soit du même type que R2 - Mais bon ici r2 = "0" donc ok pas de R2 qui compte
					#print_debug("spawn P1...")
					NetBioDyn2gui.spawn_agent(tree,"""+in_quote(p1)+""", Vector3(R1.translation.x,R1.translation.y,R1.translation.z) ) #load(str("res://SimBioCell/3-PreFabAgents/",p1,".tscn")).instance()
					R1.queue_free()
				# si R1 est ENLEVE (il est enlevé ou bien il MIME R2 mais qui vaut "0" aussi)
				if R1.is_queued_for_deletion() == false && """+in_quote(p1)+""" == "0" || """+in_quote(p1)+""" == "R2":
					R1.queue_free()
				# si P2 APPARAIT (je rappelle qu'ici R2 = 0)
				if """+in_quote(p2)+""" != "0" && """+in_quote(p2)+""" != "R1" && """+in_quote(p2)+""" != "R2" && nb_agents < tree.MAX_AGENTS: # si R2 n'est ni enlevé, ni prolongé, il est donc remplacé par P2
					NetBioDyn2gui.spawn_agent(tree,"""+in_quote(p2)+""", Vector3(R1.translation.x,R1.translation.y,R1.translation.z) ) #load(str("res://SimBioCell/3-PreFabAgents/",p2,".tscn")).instance()
				# si P2 MIME R1 il APPARAIT du meme type que R1
				if """+in_quote(p2)+""" == "R1" && nb_agents < tree.MAX_AGENTS: # si R2 n'est ni enlevé, ni prolongé, il est donc remplacé par P2
					var P2 = R1.duplicate(8) # load(str("res://SimBioCell/3-PreFabAgents/",p2,".tscn")).instance()
					P2.global_translate(Vector3(R1.translation.x,R1.translation.y,R1.translation.z))
					R1.get_parent().add_child(P2)
				# si P3 APPARAIT
				if """+in_quote(p3)+""" != "0" && """+in_quote(p3)+""" != "R1" && """+in_quote(p3)+""" != "R2" && nb_agents < tree.MAX_AGENTS: # P3 apparait
					NetBioDyn2gui.spawn_agent(tree,"""+in_quote(p3)+""", Vector3(R1.translation.x,R1.translation.y,R1.translation.z) )
				return
			# Cas avec un 2nd réactif ########################################################################################
			var bodies = R1.get_colliding_bodies()
			if bodies.size() > 0:
				#print(str("collision size:",bodies.size() ))
				#print("R1 is colliding")
				var R2 = bodies[0]
				#print( str( "List R1 : ", R1.get_meta_list()    ) )
				#print( str( "List R2 : ", R2.get_meta_list()    ) )
				#print( str("R2.get_meta(Name) : ",  R2.get_meta("Name")   ) )
				if R2 is RigidBody && R2.is_queued_for_deletion() == false && (R2.get_meta("Name") == """+in_quote(r2)+""" || R2.is_in_group("""+in_quote(r2)+""")): # R2 n'est pas détruit et appartient au bon groupe
					#print( "R2=>P2" )
					# R1 CHANGE en p1
					if R1.is_queued_for_deletion() == false && """+in_quote(p1)+""" != "0" && """+in_quote(p1)+""" != "R1" && """+in_quote(p1)+""" != "R2": # si R1 n'est ni enlevé, ni prolongé, il est donc remplacé par P1
						NetBioDyn2gui.spawn_agent(tree,"""+in_quote(p1)+""", Vector3(R1.translation.x,R1.translation.y,R1.translation.z) ) #load(str("res://SimBioCell/3-PreFabAgents/",p1,".tscn")).instance()
						R1.queue_free()
					# R1 est ENLEVE
					if R1.is_queued_for_deletion() == false && """+in_quote(p1)+""" == "0": # si R1 n'est pas prolongé, il est enlevé (càd soit enlevé soit remplacé)
						R1.queue_free()
					# R1/P1 MIME R2
					if R1.is_queued_for_deletion() == false && """+in_quote(p1)+""" == "R2": # si R1 devient P1 mais du meme type que R2
						var P1 = R2.duplicate(8) # load(str("res://SimBioCell/3-PreFabAgents/",p1,".tscn")).instance()
						P1.global_translate(Vector3(R1.translation.x,R1.translation.y,R1.translation.z))
						R1.get_parent().add_child(P1)
						R1.queue_free()
					# R2 CHANGE en p2
					if R2.is_queued_for_deletion() == false && """+in_quote(p2)+""" != "0" && """+in_quote(p2)+""" != "R1" && """+in_quote(p2)+""" != "R2" && nb_agents < tree.MAX_AGENTS: # si R2 n'est ni enlevé, ni prolongé, il est donc remplacé par P2
						NetBioDyn2gui.spawn_agent(tree,"""+in_quote(p2)+""", Vector3(R2.translation.x,R2.translation.y,R2.translation.z) ) #load(str("res://SimBioCell/3-PreFabAgents/",p2,".tscn")).instance()
						R2.queue_free()
					# R2 est ENLEVE
					if R2.is_queued_for_deletion() == false && """+in_quote(p2)+""" == "0": # si R2 est enlevé tout simplement
						R2.queue_free()
					# R1/P1 MIME R2
					if R2.is_queued_for_deletion() == false && """+in_quote(p2)+""" == "R1": # si R2 devient P2 mais du meme type que R1
						var P2 = R1.duplicate(8) # load(str("res://SimBioCell/3-PreFabAgents/",p1,".tscn")).instance()
						P2.global_translate(Vector3(R2.translation.x,R2.translation.y,R2.translation.z))
						R1.get_parent().add_child(P2)
						R2.queue_free()
					# si P3 APPARAIT
					if """+in_quote(p3)+""" != "0" && """+in_quote(p3)+""" != "R1" && """+in_quote(p3)+""" != "R2" && nb_agents < tree.MAX_AGENTS: # P3 apparait
						NetBioDyn2gui.spawn_agent(tree,"""+in_quote(p3)+""", Vector3(R1.translation.x,R1.translation.y,R1.translation.z) )

					return

"""




#██       ██████   █████  ██████          ██     ███████  █████  ██    ██ ███████ 
#██      ██    ██ ██   ██ ██   ██        ██      ██      ██   ██ ██    ██ ██      
#██      ██    ██ ███████ ██   ██       ██       ███████ ███████ ██    ██ █████   
#██      ██    ██ ██   ██ ██   ██      ██             ██ ██   ██  ██  ██  ██      
#███████  ██████  ██   ██ ██████      ██         ███████ ██   ██   ████   ███████ 
																				




# ************************************************************
#                   Load and Save Simulation                 *
# ************************************************************

# Load *******************************************************
func _on_BtnLoad_pressed():
	# Select the file to Load
	var dialog = FileDialog.new()
	dialog.mode = FileDialog.MODE_OPEN_ANY
	dialog.add_filter("*.tscn")
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	add_child(dialog)
	dialog.popup_centered_ratio()
	var filename = yield(dialog, "file_selected")
	
	# Load the simulation
	# Remove the current simu
	_node_viewport.remove_child(_node_simu)
	_node_simu.call_deferred("free")

	# Add the next level
	var next_simu_res = load(filename) #load("res://Simulations/Simu.tscn")
	if next_simu_res == null:
		print(str("Impossible to read file: ", filename))
		return
	var next_simu_node = next_simu_res.instance()
	
	# TO DO : verify the tree structure before loading it (Nodes Simulator, then Entities, Behaviors ,etc)
	
	# The structure is ok => attach it to the Viewport
	_node_viewport.add_child(next_simu_node)
	
	# re-init 3D node variables
	_node_camera	= next_simu_node.get_node("Camera")
	_node_simu 		= next_simu_node
	_node_entities 	= next_simu_node.get_node("Entities")
	_node_behavs 	= next_simu_node.get_node("Behaviors")
	_node_env 		= next_simu_node.get_node("Environment")
	_node_groups	= next_simu_node.get_node("Groups")

	# Empty the 2D GUI
	_listAgents.clear()
	_listBehavs.clear()
	
	# Fill the 2D GUI with agents, behaviors, groups and grids
	for agt in _node_entities.get_children():
		_listAgents.add_item(agt.name)
	for agt in _node_behavs.get_children():
		_listBehavs.add_item(agt.get_meta("Name"))
	set_group_from_simulator_to_GUI()

# Save *****************************************************
func _on_BtnSave_pressed():
	# Select the file to Save
	var dialog = FileDialog.new()
	dialog.mode = FileDialog.MODE_SAVE_FILE
	dialog.add_filter("*.tscn")
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	add_child(dialog)
	dialog.popup_centered_ratio()
	var filename = yield(dialog, "file_selected")
	
	# Duplicate the node (prevents an error)
	var simu = _node_simu.duplicate(15) #.duplicate_and_reown()

	# Setting simu node as owner of all its
	# children for saving reasons
	set_owner_recursive(simu, simu)

	# Debug : verify the goups before saving
	var rb:RigidBody = get_entity(_selected_name)
	var lst_gp = rb.get_groups()
	print(str("For agent :", rb.name))
	print(str("Nb groups = ", lst_gp.size()))
	for gp in lst_gp:
		print(gp)

	# Continue to save
	var save_build  = PackedScene.new()
	save_build.pack(simu)
	ResourceSaver.save(filename, save_build)

func set_owner_recursive(root:Node, node:Node)->void:
	for child in node.get_children():
		child.set_owner(root)
		set_owner_recursive(root, child)



# ██████  ██████   █████  ██████  ██   ██ 
#██       ██   ██ ██   ██ ██   ██ ██   ██ 
#██   ███ ██████  ███████ ██████  ███████ 
#██    ██ ██   ██ ██   ██ ██      ██   ██ 
# ██████  ██   ██ ██   ██ ██      ██   ██



# ************************************************
#                       GRAPH                    *
# ************************************************

#var points_graph = PoolVector2Array()
func manage_graph() -> void:
	pass
#	if _node_env == null:
#		return
#	# Create the curve : TODO must be created at Play (_step = 0 only)
#
#	# Panel to draw the graph
#	var gfx:Node = get_node("%TextureGraph")
#
#	# Add new points
#	points_graph.push_back( Vector2(_step, _node_env.get_child_count()))
#
#	# Draw graph
#	var color:Color = Color(0.6 , 1 , 0.3)
#
#	#for i in range(1, points_graph.size()):
#	var texture = gfx.get_texture()
#	var img:Image = texture.get_data()
#
#	img.lock()
#	img.set_pixel(  128 , 128 , Color(0,0,1,1)  )
#	img.unlock()

	#	gfx.get_texture().draw_line(points_graph[i-1], points_graph[i], color)





#████████  ██████      ██████   ██████  
#   ██    ██    ██     ██   ██ ██    ██ 
#   ██    ██    ██     ██   ██ ██    ██ 
#   ██    ██    ██     ██   ██ ██    ██ 
#   ██     ██████      ██████   ██████  
									  




# ************************************************
#                       TODO                     *
# ************************************************

#placer des listes déroulantes pour les agents / groupe dans les comportements

# ************************************************
# WORK in PROGRESS...
# ************************************************
func _on_BtnDebug_pressed():
	var img = Image.new()
	img.create(256, 256, false, Image.FORMAT_RGB8)
	img.lock()
	for x in 128:
		for y in 128:
			img.set_pixel(x, y, Color(128, 128, 128) )
	img.unlock()
	
	#Create the texture
	var tex=ImageTexture.new()
	#tex.set_data(img)
	tex.create_from_image ( img )
	
	# Put the texture
	var gfx:Node = get_node("%TextureGraph")
	gfx.set_texture(tex)


func group_line_edit_on_focus()->void:
	var tabs:TabContainer = get_node("%TabContainer")
	tabs.current_tab = Prop.GROUP
