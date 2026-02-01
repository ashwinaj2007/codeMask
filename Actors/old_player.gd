extends CharacterBody2D

# Constants
const SPEED = 150.0 * 2
const JUMP_VELOCITY = -350.0 * 2
const GRAVITY = 800.0 * 2
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D


# Mask State
var mask_state = "RED" # Default to Command Mask
signal mask_changed(new_mask_state)

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle Horizontal Movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction != 0:
		velocity.x = direction * SPEED
		if anim.current_animation != "walk":
			anim.play("walk")

		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if anim.current_animation != "idle":
			anim.play("idle")


	move_and_slide()

# ... (inside Player.gd) ...

#func _input(event):
#	if event.is_action_just_pressed("switch_mask"):
#		toggle_mask()

func _process(delta):
	if Input.is_action_just_pressed("switch_mask"):
		toggle_mask()

func toggle_mask():
	if mask_state == "RED":
		mask_state = "BLUE"
		$Sprite2D.modulate = Color.BLUE
		print("Switched to BLUE Mask (Ghost)")
	else:
		mask_state = "RED"
		$Sprite2D.modulate = Color.RED
		print("Switched to RED Mask (Command)")

	emit_signal("mask_changed", mask_state)

func _ready():
	mask_state = "RED"
	$Sprite2D.modulate = Color.RED
	emit_signal("mask_changed", mask_state)
