extends Node2D
class_name Player

@export var stats: Stats : set = set_player_stats

@onready var box: TextureRect = $TextureRect
@onready var stats_ui: StatsUI = $StatsUI as StatsUI

func set_player_stats(val: Stats):
	stats = val.create_instance()
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
		
	update_player()
	
func update_stats():
	stats_ui.update_stats(stats)
	
func update_player():
	if not stats is Stats:
		return
	if not is_inside_tree():
		await ready
	# should create a flexible enemy drawer
	update_stats()
	
func take_damage(dmg: int):
	if stats.health <= 0:
		return
	stats.take_damage(dmg, "player")
	
