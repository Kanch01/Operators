extends Node2D
class_name Enemy
@export var stats: Stats : set = set_enemy_stats

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stats_ui = $".".get_node("/root/Run/SceneContainer/BB/EHealth")
@onready var timer: Timer = $Timer
@onready var battle = $".".get_node("/root/Run/SceneContainer/BB")
@onready var player: AudioStreamPlayer = $Noises
@onready var b_timer: Timer = $".".get_node("/root/Run/SceneContainer/BB/BattleTimer")

var output: int
var path_var: String
var attack_time: int

var pos_statuses: Array = ["Blind", "Para", "Rage", "Burn", "DisI", "DisP"]
var status_calls = {"Blind": Callable(self, "blinded"), "Para": Callable(self, "paralyzed"), "Rage": Callable(self, "enraged"), "Burn": Callable(self, "burned"), "DisI": Callable(self, "idisable"), "DisP": Callable(self, "pdisabled")}

signal boss_enemy_done
signal health_depleted

func _ready():
	if Gamestate.tflors != Gamestate.floors:
		var tier
		if Gamestate.floors <= 2:
			tier = "low"
		elif Gamestate.floors < 9:
			tier = "mid"
		else:
			tier = "high"
	
		output = Gamestate.enemies.get(tier).get("dmg")
		timer.set_meta("DMG", output)
		timer.timeout.connect(_attack)
		
		attack_time = Gamestate.enemies.get(tier).get("time")
		if Gamestate.ability == "Rapid Strike" and Gamestate.quick_takedown == true:
			attack_time = attack_time + (attack_time / 3)
		
		sprite.animation_finished.connect(_ui_changes)
	else:
		sprite.animation_finished.connect(boss_seq)
		
	path_var = str(timer.get_parent().name)
	
	
	# timer.start(attack_time)
	
func roll_status():
	var roll = randi() % Gamestate.enemies.get(Gamestate.difficulty).get("status_odds") + 1
	if roll == 1:
		var status = status_calls.get(pos_statuses[randi_range(0, 6)])
		status.call()

func blinded():
	pass
	
func paralyzed():
	pass
	
func enraged():
	pass
	
func burned():
	pass
	
func idisabled():
	pass
	
func pdisabled():
	pass

func start_etimer():
	timer.start(attack_time)

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
	
func other_damage(dmg: int):
	# enemy still isn't dying must figure out
	if stats.health <= dmg:
		print("enemy has died")
		timer.stop()
		if dmg == stats.max_health and Gamestate.one_shot == true:
			Gamestate.pstats.max_health += 5
			Gamestate.pstats.heal(5)
				
		b_timer.stop()
		player.stream = load("res://sounds/" + path_var + "/death.mp3")
		player.play()
		sprite.animation = "death"
		sprite.play()
		stats_ui.value = 0
		stats_ui.get_child(0).text = "0/0"
		emit_signal("health_depleted")
		Gamestate.sacrifice = false
	else:
		player.stream = load("res://sounds/" + path_var + "/hurt.mp3")
		player.play()
		sprite.play("hurt")
		stats.subtraction_dmg(dmg)
	
func take_damage(dmg: int):
	if stats.health == dmg:
		if dmg == stats.max_health and Gamestate.one_shot == true:
			Gamestate.pstats.max_health += 5
			Gamestate.pstats.heal(5)
			
		b_timer.stop()
		
		if Gamestate.tflors != Gamestate.floors:
			player.stream = load("res://sounds/" + path_var + "/death.mp3")
			player.play()
			
		sprite.animation = "death"
		sprite.play()
		stats_ui.value = 0
		stats_ui.get_child(0).text = "0/0"
		stats.health = 0
		emit_signal("health_depleted")
	elif stats.health % dmg == 0:
		player.stream = load("res://sounds/" + path_var + "/hurt.mp3")
		player.play()
		sprite.play("hurt")
		stats.take_damage(dmg, "enemy")
	else:
		return
	
func _attack():
	if stats.health != 0:
		player.stream = load("res://sounds/" + path_var + "/attack.mp3")
		if path_var == "enemy_c":
			sprite.play("attack")
			player.play()
			await get_tree().create_timer(0.5).timeout
			player.stop()
			player.play()
		elif path_var == "enemy_h":
			player.play(0.67)
			sprite.play("attack")
		else:
			player.play()
			sprite.play("attack")
	
func _ui_changes():
	if sprite.animation == "death":
		if player.stream.get_length() >= 5.0:
			await get_tree().create_timer(5.0).timeout
		else:
			await player.finished
		stats_ui.visible = false
		sprite.visible = false
		$".".get_node("/root/Run/SceneContainer/BB").win_screen()
	if sprite.animation == "attack":		
		battle.player_hit(timer.get_meta("DMG"))
	if sprite.animation == "hurt":
		sprite.play("idle")
	if Gamestate.pstats.health <= 0:
		# later change for game over screen
		var par = get_tree().root
		par.get_node("Run").show_scene("main_menu")
		
func boss_seq():
	if sprite.animation == "hurt":
		sprite.play("idle")
	if sprite.animation == "death":
		var tw = create_tween()
		tw.tween_property(sprite, "modulate:a", 0.0, 0.6)
		await tw.finished
		emit_signal("boss_enemy_done")
		queue_free()
	
	
	
