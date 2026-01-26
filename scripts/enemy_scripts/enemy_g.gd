extends Node2D
@export var stats: Stats : set = set_enemy_stats

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stats_ui: StatsUI = $StatsUI as StatsUI
@onready var aniplayer = $".".get_node("/root/Run/SceneContainer/BB/AnimationPlayer")
@onready var progress = $".".get_node("/root/Run/SceneContainer/BB/Health")
@onready var camera = $".".get_node("/root/Run/SceneContainer/BB/Camera2D")


func set_enemy_stats(val: Stats):
	stats = val.create_instance()
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
		
	update_enemy()
	
func update_stats():
	stats_ui.update_stats(stats)
	
func update_enemy():
	if not stats is Stats:
		return
	if not is_inside_tree():
		await ready
	# should create a flexible enemy drawer
	update_stats()
	
func take_damage(dmg: int):
	if stats.health <= 0:
		return
	stats.take_damage(dmg, "enemy")

func _on_timer_timeout() -> void:
	sprite.play("attack")

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "death":
		queue_free()
		$".".get_node("/root/Run/SceneContainer/BB").win_screen()
	if sprite.animation == "attack":
		aniplayer.play("new_animation")
		camera.shake(0.2, 6)
		Gamestate.pstats.take_damage(7, "player")
		progress.value = Gamestate.pstats.health
		progress.get_child(0).text = str(int(progress.value)) + "/" + str(int(progress.max_value))
	sprite.play("idle")
