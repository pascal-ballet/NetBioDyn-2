extends Node

var node_agents	:Node
var node_behavs	:Node
var node_status	:Label
var step:int = 0

func _ready():
	node_agents 	= get_node("%Environment")
	node_behavs 	= get_node("%Behaviors")
	node_status 	= get_node("%LabelStatusbar")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# MANAGE Simulator Control (PLAY / STEP / PAUSE / STOP)
	if NetBioDyn2gui._sim_play == false:
		return
		
	if NetBioDyn2gui._sim_play == true && NetBioDyn2gui._sim_pause == true && NetBioDyn2gui._sim_step == false:
		return
		
	if NetBioDyn2gui._sim_step == true:
		NetBioDyn2gui._sim_step = false
		
	# PLAY ONE step
	if step % 1 == 0:	
		var nb_agents:int = node_agents.get_child_count()
		var nb_behavs:int = node_behavs.get_child_count()
		node_status.text = str("step=", step, " | Nb agents=", nb_agents, " | Nb behaviors=", nb_behavs)
		
	for behav in get_children():
		for entity in node_agents.get_children(): #ou bien for agt in get_all_from_group("Virus"):
			behav.step(entity) #on applique le comportement behav sur l'agent agt

	step = step + 1

# ************************************************
# WORK in PROGRESS...
# ************************************************

