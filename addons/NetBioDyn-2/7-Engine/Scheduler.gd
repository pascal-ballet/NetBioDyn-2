extends Node


var entityInstances:Node
func _ready():
	entityInstances = get_node("../EntityInstances")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for behav in get_children():
		for entity in entityInstances.get_children(): #ou bien for agt in get_all_from_group("Virus"):
			behav.step(entity) #on applique le comportement behav sur l'agent agt
