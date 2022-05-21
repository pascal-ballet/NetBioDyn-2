tool
extends VisualScriptCustomNode

# TODO
# - add R1 for P2
# - add R2 for P1
# => could be enhanced by a more comprehensible switch case

var MAX_AGENTS:int = 500

func _get_caption():
	return "Reaction"

func _get_category():
	return "SimCells"

# *************
# *   STEP    *
# *************
func _step(inputs, outputs, start_mode, working_mem):
	var made:bool = false
	var alea = rand_range(0,1)
	if alea > inputs[1]: # si la proba n'est pas vérifiée => la réaction ne se produit pas
		#print("proba=", inputs[1], " >= ", alea)
		made = true
		return 0
	var R1 = inputs[0]
	var nb_agents = R1.get_parent().get_child_count()
	#print ("nb=", nb_agents)
	if R1.is_queued_for_deletion() == false && R1.is_in_group(inputs[2]): # R1 n'est pas déjà détruit et il appartien au bon groupe
		#print("R1 is in gp : ", inputs[2])
		# Cas avec R2 == 0
		if inputs[3] == "0": # Pas de 2nd réactif => toujours appliqué (à la proba près)
			if inputs[4] != "0" && inputs[4] != "R1": # si R1 n'est ni enlevé, ni prolongé, il est donc remplacé par P1
				var P1 = load(str("res://SimBioCell/2-PreFabAgents/",inputs[4],".tscn")).instance()
				P1.global_translate(Vector3(R1.translation.x,R1.translation.y,R1.translation.z))
				R1.get_parent().add_child(P1)
			if inputs[5] != "0" && inputs[5] != "R2" && nb_agents < MAX_AGENTS: # si R2 n'est ni enlevé, ni prolongé, il est donc remplacé par P2
				var P2 = load(str("res://SimBioCell/2-PreFabAgents/",inputs[5],".tscn")).instance()
				P2.global_translate(Vector3(R1.translation.x,R1.translation.y,R1.translation.z))
				R1.get_parent().add_child(P2)
			if inputs[4] != "R1": # si R1 n'est pas prolongé, il est enlevé (càd soit enlevé soit remplacé)
				R1.queue_free()
			made = true
			return 0
		var bodies = R1.get_colliding_bodies()
		if bodies.size() > 0: # Cas avec un 2nd réactif
			#print("R1 is colliding")
			var R2 = bodies[0]
			if R2.is_queued_for_deletion() == false && R2.is_in_group(inputs[3]): # R2 n'est pas détruit et appartient au bon groupe
				#print("with another")
				if inputs[4] != "0" && inputs[4] != "R1": # si R1 n'est ni enlevé, ni prolongé, il est donc remplacé par P1
					var P1 = load(str("res://SimBioCell/2-PreFabAgents/",inputs[4],".tscn")).instance()
					P1.global_translate(Vector3(R1.translation.x,R1.translation.y,R1.translation.z))
					R1.get_parent().add_child(P1)
				if inputs[5] != "0" && inputs[5] != "R2" && nb_agents < MAX_AGENTS: # si R2 n'est ni enlevé, ni prolongé, il est donc remplacé par P2
					var P2 = load(str("res://SimBioCell/2-PreFabAgents/",inputs[5],".tscn")).instance()
					P2.global_translate(Vector3(R2.translation.x,R2.translation.y,R2.translation.z))
					R1.get_parent().add_child(P2)
				if inputs[4] != "R1": # si R1 n'est pas prolongé, il est enlevé (càd soit enlevé soit remplacé)
					R1.queue_free()
				if inputs[5] != "R2": # si R2 n'est pas prolongé, il est enlevé (càd soit enlevé soit remplacé)
					R2.queue_free()
				made = true
	outputs[0] = made # in the box, return true if the reaction has been made, else it returns false
	return 0

# **************
# *  SEQUENCE  *
# **************
func _has_input_sequence_port():
	return true
func _get_output_sequence_port_count():
	return 1

# *************
# *  INPUT   *
# *************
func _get_input_value_port_count():
	return 6
func _get_input_value_port_name(idx):
	if idx == 0:
		return "Agent"
	elif idx == 1:
		return "Proba"
	elif idx == 2:
		return "Reactive Gp R1"
	elif idx == 3:
		return "Reactive Gp R2/0"
	elif idx == 4:
		return "Product PreFab/0/R1/R2"
	elif idx == 5:
		return "Product PreFab/0/R1/R2"
	return "default"
func _get_input_value_port_type(idx):
	if idx == 0:
		return RigidBody
	elif idx == 1:
		return TYPE_REAL
	elif idx == 2:
		return TYPE_STRING
	elif idx == 3:
		return TYPE_STRING
	elif idx == 4:
		return TYPE_STRING
	elif idx == 5:
		return TYPE_STRING
	return TYPE_OBJECT

# *************
# *  OUTPUT   *
# *************
func _get_output_value_port_count():
	return 1
func _get_output_value_port_name(idx):
	if idx == 0:
		return "Made"
	return "default"
func _get_output_value_port_type(idx):
	if idx == 0:
		return TYPE_BOOL
	return TYPE_OBJECT
