extends HBoxContainer
class_name StatsUI

@onready var health: HBoxContainer = $Health
@onready var health_amt: Label = %HealthAmt
@onready var shield: HBoxContainer = $Shield
@onready var shield_amt: Label = %ShieldAmt

func update_stats(stats: Stats):
	shield_amt.text = str(stats.shield)
	health_amt.text = str(stats.health)
	
	health.visible = stats.health > 0
	shield.visible = stats.shield > 0
