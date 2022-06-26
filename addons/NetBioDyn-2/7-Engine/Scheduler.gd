extends Node


var env:Node
func _ready():
	env = get_node("../Envirnment")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for behav in get_children():
		for entity in env.get_children(): #ou bien for agt in get_all_from_group("Virus"):
			behav.step(entity) #on applique le comportement behav sur l'agent agt
