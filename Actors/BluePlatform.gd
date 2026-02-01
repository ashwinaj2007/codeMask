extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	# Start hidden & non-solid
	set_active(false)

	# Connect to player's mask signal
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.mask_changed.connect(on_mask_changed)

func on_mask_changed(mask_state):
	if mask_state == "BLUE":
		set_active(true)
	else:
		set_active(false)

func set_active(active: bool):
	sprite.visible = active
	collision.disabled = not active
