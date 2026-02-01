extends CharacterBody2D

@export var patrol_speed := 100.0
@export var path_follow: PathFollow2D
@export var detection_time := 0.5

var direction := 1
var player_visible := false
var player_ref: CharacterBody2D = null
var detect_timer := 0.0

# Door logic
var moving_to_door := false
var door_target: Node2D = null

@onready var vision_visual = $VisionVisual
@onready var alert_bar = $AlertUI/AlertBar
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer

func _ready():
	alert_bar.visible = false
	alert_bar.value = 0.0
	anim.play("guard_walk")

func _process(delta):
	# HIGHEST PRIORITY: walk to door
	if moving_to_door and door_target:
		move_to_door(delta)
		return

	# Player detection (only RED mask)
	if player_visible and player_ref != null and player_ref.mask_state == "RED":
		detect_timer += delta
		alert_bar.visible = true
		alert_bar.value = clamp(detect_timer / detection_time, 0.0, 1.0)

		if detect_timer >= detection_time:
			kill_player()
	else:
		detect_timer = max(detect_timer - delta * 2.0, 0.0)
		alert_bar.value = clamp(detect_timer / detection_time, 0.0, 1.0)

		if detect_timer <= 0.01:
			alert_bar.visible = false

		patrol(delta)

func patrol(delta):
	if path_follow == null:
		anim.play("idle")
		return

	path_follow.progress += patrol_speed * delta * direction

	if path_follow.progress_ratio >= 1.0 or path_follow.progress_ratio <= 0.0:
		direction *= -1

	global_position = path_follow.global_position
	anim.play("guard_walk")
	update_facing()

func move_to_door(delta):
	var dir = (door_target.global_position - global_position).normalized()
	velocity.x = dir.x * patrol_speed
	move_and_slide()

	anim.play("guard_walk")
	update_facing()

	if global_position.distance_to(door_target.global_position) < 20.0:
		velocity = Vector2.ZERO
		moving_to_door = false

func update_facing():
	if direction > 0:
		scale.x = -1
	else:
		scale.x = 1

func go_to_door(door: Node2D):
	door_target = door
	moving_to_door = true

func on_mask_changed(mask):
	vision_visual.visible = (mask == "RED")

func kill_player():
	var door = get_tree().get_first_node_in_group("exit_door")
	if door and door.player_in_range:
		get_tree().change_scene_to_file("res://Scenes/BadEnding.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_visible = true
		player_ref = body

func _on_vision_area_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_visible = false
		player_ref = null
