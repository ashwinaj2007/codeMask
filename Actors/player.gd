extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -700.0
const GRAVITY = 1600.0

@onready var sprite = $AnimatedSprite2D
@onready var jump_sound = $JumpSound
@onready var walk_sound = $WalkSound

var mask_state = "RED"
signal mask_changed(new_mask_state)

func _ready():
	mask_state = "RED"
	sprite.modulate = Color.RED
	emit_signal("mask_changed", mask_state)

func _process(_delta):
	if Input.is_action_just_pressed("switch_mask"):
		toggle_mask()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		sprite.play("jump")
		stop_walk_sound()

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sprite.play("jump")
		jump_sound.play()
		stop_walk_sound()

	var direction = Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
		if is_on_floor():
			sprite.play("walk")
			play_walk_sound()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			sprite.play("idle")
			stop_walk_sound()

	move_and_slide()

func toggle_mask():
	if mask_state == "RED":
		mask_state = "BLUE"
		sprite.modulate = Color.BLUE
	else:
		mask_state = "RED"
		sprite.modulate = Color.RED

	emit_signal("mask_changed", mask_state)

func play_walk_sound():
	if not walk_sound.playing:
		walk_sound.play()

func stop_walk_sound():
	if walk_sound.playing:
		walk_sound.stop()
