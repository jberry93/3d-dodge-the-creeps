extends CharacterBody3D

# Emitted when the player jumps on the mob
signal squashed

# Minimum speed of the mob in meters per second
@export var min_speed = 10

# Maximum speed of the mob in meters per second
@export var max_speed = 10

func squash() -> void:
	squashed.emit()
	queue_free()

func _physics_process(_delta: float) -> void:
	move_and_slide()

# Called from the main scene
func initialize(start_position, player_position) -> void:
	# Position the mob by placing it at a "start_position" and rotate
	# it towards the "player_position" so it looks at they player
	look_at_from_position(start_position, player_position, Vector3.UP)
	
	# Rotate this mob randomly within range of -45 and +45 degrees so
	# that it does not move directly towards the player
	rotate_y(randf_range(-PI / 4, PI / 4))
	
	# Calculate a random speed (integer)
	var random_speed: int = randi_range(min_speed, max_speed)
	
	# Calculate a forward velocity that represents the speed
	velocity = Vector3.FORWARD * random_speed
	
	# Rotate the velocity vecotr based on the mob's Y rotation
	# in order to move in the direction the mob is looking
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
	$AnimationPlayer.speed_scale = random_speed / min_speed

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
