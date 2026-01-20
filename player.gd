extends CharacterBody3D

# Emitted when the player is hit by a mob
signal hit

# How fast the player moves in meters per second
@export var speed = 14

# The downward acceleration when in the air, in meters per second
@export var fall_acceleration = 75

# Vertical impulse applied to the player upon jumping in meters per second
@export var jump_impulse = 20

# Vertical impulse applied to the player upon bouncing over a mob in meters per second
@export var bounce_impulse = 16

var target_velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	# We create a local variable to store the input direction
	var direction = Vector3.ZERO
	
	# We check for each move input and update the direction accordingly
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		
		# Setting the basis property will affect the rotation of the node
		$Pivot.basis = Basis.looking_at(direction)
	
	# Ground velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	# Vertical velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		
	# Jump!
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
		
	# Iterate through all collisions that have occurred this frame
	for index: int in range(get_slide_collision_count()):
		# Grab a collision with the player and the object the player collided with
		var collision: KinematicCollision3D = get_slide_collision(index)
		var collidedObject: Object = collision.get_collider()
		
		# Prevent duplicate collisions
		if collidedObject == null:
			continue
			
		var isCollidedObjectAMob: bool = collidedObject.is_in_group("mob")
		if isCollidedObjectAMob:
			var mob: Object = collidedObject
			
			# Check to see if the player landed on top of the mob.
			# This can be finicky since the collider on the player is a sphere
			# while the collider on the mob is a box. Other ways of fixing this
			# would be to either make the player collision sphere smaller or
			# make the mob collision box taller. In this case, I chose to increase
			# the threshold for determining the downward collision
			if Vector3.UP.dot(collision.get_normal()) > 0.75:
				# "Squash" the mob, "bounce" the player up again, and stop the loop
				mob.squash()
				target_velocity.y = bounce_impulse
				break;
		
	# Moving the character
	velocity = target_velocity
	move_and_slide()

func die():
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(_body: Node3D) -> void:
	die()
