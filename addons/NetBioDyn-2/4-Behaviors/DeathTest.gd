extends Node

func step(agent) -> void:
	var proba:float = 0.01
	if rand_range(0,100) < proba:
		#print("DEAD")
		agent.queue_free()
