extends TextureProgressBar
class_name holder

@onready var health: Label = $EAMT

func update_stats(stats: Stats):
	if value == 1:
		visible = false
	max_value = stats.max_health
	value = stats.health
	health.text = str(stats.health) + "/" + str(stats.max_health)
