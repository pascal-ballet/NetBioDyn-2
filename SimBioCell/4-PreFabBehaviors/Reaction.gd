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
	var made:bool 	= false
	var alea:float 	= rand_range(0,1)
	if alea > inputs[1]: # si la proba n'est pas vérifiée => la réaction ne se produit pas
		#print("proba=", inputs[1], " >= ", alea)
		outputs[0] = false
		return 0
	var R1:Spatial 		= inputs[0]
	var nb_agents:int 	= R1.get_parent().get_child_count()
	#print ("nb=", nb_agents)
	var r1 = inputs[2] # Reactive 1
	var r2 = inputs[3] # Reactive 2
	var p1 = inputs[4] # Product  1
	var p2 = inputs[5] # Product  2
	if R1.is_queued_for_deletion() == false && R1.is_in_group(r1): # R1 n'est pas déjà détruit et il appartient au bon groupe
		#print("R1 is in gp : ", inputs[2])
		# Cas avec R2 == 0 ########################################################################################
		if r2 == "0": # Pas de 2nd réactif => toujours appliqué (à la proba précédente près)
			# si R1 CHANGE en P1 (il n'est ni enlevé, ni prolongé, il est donc remplacé par P1)
			if p1 != "0" && p1 != "R1" && p1 != "R2":
				var P1 = null # et P1 peut être soit un nouvel agent soit du même type que R2 - Mais bon ici r2 = "0" donc ok pas de R2 qui compte
				P1 = load(str("res://SimBioCell/3-PreFabAgents/",p1,".tscn")).instance()
				P1.global_translate(Vector3(R1.translation.x,R1.translation.y,R1.translation.z))
				R1.get_parent().add_child(P1)
				R1.queue_free()
			# si R1 est ENLEVE (il est enlevé ou bien il MIME R2 mais qui vaut "0" aussi)
			if p1 == "0" || p1 == "R2":
				R1.queue_free()
			# si P2 APPARAIT (je rappelle qu'ici R2 = 0)				
			if p2 != "0" && p2 != "R1" && p2 != "R2" && nb_agents < MAX_AGENTS: # si R2 n'est ni enlevé, ni prolongé, il est donc remplacé par P2
				var P2 = load(str("res://SimBioCell/3-PreFabAgents/",p2,".tscn")).instance()
				P2.global_translate(Vector3(R1.translation.x,R1.translation.y,R1.translation.z))
				R1.get_parent().add_child(P2)
			# si P2 MIME R1 il APPARAIT du meme type que R1
			if p2 == "R1" && nb_agents < MAX_AGENTS: # si R2 n'est ni enlevé, ni prolongé, il est donc remplacé par P2
				var P2 = R1.duplicate(8) # load(str("res://SimBioCell/3-PreFabAgents/",p2,".tscn")).instance()
				P2.global_translate(Vector3(R1.translation.x,R1.translation.y,R1.translation.z))
				R1.get_parent().add_child(P2)
			outputs[0] = true
			return 0
		# Cas avec un 2nd réactif ########################################################################################
		var bodies = R1.get_colliding_bodies()
		if bodies.size() > 0:
			#print("R1 is colliding")
			var R2 = bodies[0]
			if R2.is_queued_for_deletion() == false && R2.is_in_group(r2): # R2 n'est pas détruit et appartient au bon groupe
				# R1 CHANGE en p1
				if p1 != "0" && p1 != "R1" && p1 != "R2": # si R1 n'est ni enlevé, ni prolongé, il est donc remplacé par P1
					var P1 = load(str("res://SimBioCell/3-PreFabAgents/",p1,".tscn")).instance()
					P1.global_translate(Vector3(R1.translation.x,R1.translation.y,R1.translation.z))
					R1.get_parent().add_child(P1)
					R1.queue_free()
				# R1 est ENLEVE
				if p1 == "0": # si R1 n'est pas prolongé, il est enlevé (càd soit enlevé soit remplacé)
					R1.queue_free()
				# R1/P1 MIME R2
				if p1 == "R2": # si R1 devient P1 mais du meme type que R2
					var P1 = R2.duplicate(8) # load(str("res://SimBioCell/3-PreFabAgents/",p1,".tscn")).instance()
					P1.global_translate(Vector3(R1.translation.x,R1.translation.y,R1.translation.z))
					R1.get_parent().add_child(P1)
					R1.queue_free()
				# R2 CHANGE en p2
				if p2 != "0" && p2 != "R1" && p2 != "R2" && nb_agents < MAX_AGENTS: # si R2 n'est ni enlevé, ni prolongé, il est donc remplacé par P2
					var P2 = load(str("res://SimBioCell/3-PreFabAgents/",p2,".tscn")).instance()
					P2.global_translate(Vector3(R2.translation.x,R2.translation.y,R2.translation.z))
					R1.get_parent().add_child(P2)
					R2.queue_free()
				# R2 est ENLEVE
				if p2 == "0": # si R2 est enlevé tout simplement
					R2.queue_free()
				# R1/P1 MIME R2
				if p2 == "R1": # si R2 devient P2 mais du meme type que R1
					var P2 = R1.duplicate(8) # load(str("res://SimBioCell/3-PreFabAgents/",p1,".tscn")).instance()
					P2.global_translate(Vector3(R2.translation.x,R2.translation.y,R2.translation.z))
					R1.get_parent().add_child(P2)
					R2.queue_free()
				made = true
	outputs[0] = made # in the box, return true if the reaction has been made, else it returns false
	return 0

func _step_old(inputs, outputs, start_mode, working_mem):
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
				var P1 = load(str("res://SimBioCell/3-PreFabAgents/",inputs[4],".tscn")).instance()
				P1.global_translate(Vector3(R1.translation.x,R1.translation.y,R1.translation.z))
				R1.get_parent().add_child(P1)
			if inputs[5] != "0" && inputs[5] != "R2" && nb_agents < MAX_AGENTS: # si R2 n'est ni enlevé, ni prolongé, il est donc remplacé par P2
				var P2 = load(str("res://SimBioCell/3-PreFabAgents/",inputs[5],".tscn")).instance()
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
				if inputs[4] != "0" && inputs[4] != "R1" && inputs[4] != "R2": # si R1 n'est ni enlevé, ni prolongé, il est donc remplacé par P1
					var P1 = load(str("res://SimBioCell/3-PreFabAgents/",inputs[4],".tscn")).instance()
					P1.global_translate(Vector3(R1.translation.x,R1.translation.y,R1.translation.z))
					R1.get_parent().add_child(P1)
				if inputs[5] != "0" && inputs[5] != "R1" && inputs[5] != "R2" && nb_agents < MAX_AGENTS: # si R2 n'est ni enlevé, ni prolongé, il est donc remplacé par P2
					var P2 = load(str("res://SimBioCell/3-PreFabAgents/",inputs[5],".tscn")).instance()
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
