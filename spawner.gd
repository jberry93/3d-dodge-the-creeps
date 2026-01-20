extends Node

@export var mob_scene: PackedScene

func _ready() -> void:
	$UserInterface/Retry.hide()

func _on_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene
	var mob: Node = mob_scene.instantiate()
	
	# Choose a random location on the SpawnPath. Store the reference
	# to the SpawnLocation node.
	var mob_spawn_location: Node = get_node("SpawnPath/SpawnLocation")
	# Give a random offset
	mob_spawn_location.progress_ratio = randf()
	
	var player_position: Variant = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)
	
	# Spawn the mob
	add_child(mob)
	
	# Connect the mob to the score label to update the score upon squashing one
	mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())

func _on_player_hit() -> void:
	$MobTimer.stop()
	$UserInterface/Retry.show()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()
