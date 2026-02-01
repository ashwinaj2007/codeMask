extends Node2D

func _ready():
	var player = $Player

	for guard in get_tree().get_nodes_in_group("guards"):
		player.connect("mask_changed", guard.on_mask_changed)
