extends StaticBody2D

var player_in_range := false
var guard_near := false
var opened := false
var guard_called := false

@onready var prompt: Label = $EscapePrompt

func _ready():
	prompt.visible = false

func _process(_delta):
	if opened:
		return

	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return

	# Auto-call nearest guard when player is in COMMAND (RED) mask
	if player_in_range and player.mask_state == "RED" and not guard_called:
		call_nearest_guard()
		guard_called = true

	# Show UI prompt only when escape is actually possible
	prompt.visible = player_in_range and guard_near

	# Escape input (Q)
	if player_in_range and player.mask_state == "RED" and guard_near and Input.is_action_just_pressed("escape_action"):
		open_door()

func call_nearest_guard():
	var guards = get_tree().get_nodes_in_group("guards")
	if guards.is_empty():
		return

	var nearest_guard = guards[0]
	var shortest = nearest_guard.global_position.distance_to(global_position)

	for g in guards:
		var d = g.global_position.distance_to(global_position)
		if d < shortest:
			shortest = d
			nearest_guard = g

	nearest_guard.go_to_door(self)

func open_door():
	opened = true
	get_tree().change_scene_to_file("res://Scenes/victory.tscn")

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true

	if body.is_in_group("guards"):
		guard_near = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false

	if body.is_in_group("guards"):
		guard_near = false
