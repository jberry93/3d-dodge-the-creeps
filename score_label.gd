extends Label

var score = 0

## Increment the score and update the label
func _on_mob_squashed() -> void:
	score += 1
	text = "Score: %s" % score
