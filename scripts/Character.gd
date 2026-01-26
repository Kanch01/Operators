extends Node
class_name Stats

signal stats_changed

@export var max_health := 1
@export var art: Texture

var health: int : set = set_health
var shield: int : set = set_shield

func set_health(val: int):
	health = clampi(val, 0, max_health)
	stats_changed.emit()
	
func set_shield(val: int):
	shield = clampi(val, 0, 999)
	stats_changed.emit()
	
func subtraction_dmg(dmg: int):
	if dmg <= 0:
		return
	health -= dmg
	
	Gamestate.sacrifice = false

func take_damage(dmg: int, type: String):
	if type == "enemy":
		if dmg <= 0:
			return
		if self.health % dmg == 0:
			self.health = self.health / dmg
	else:
		if dmg <= 0:
			return
		var idmg = dmg
		dmg = clampi(dmg - shield, 0, dmg)
		self.shield = clampi(shield - idmg, 0, shield)
		self.health -= dmg
	
func heal(amt: int):
	self.health += amt
	
func create_instance():
	var instance: Stats = self.duplicate()
	instance.health = max_health
	instance.shield = 0
	return instance
