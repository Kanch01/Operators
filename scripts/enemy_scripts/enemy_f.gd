extends Node2D

@onready var boss: AnimatedSprite2D = $AnimatedSprite2D
@onready var battle = $".".get_node("/root/Run/SceneContainer/BB")
@onready var text_display = $".".get_node("/root/Run/SceneContainer/BB/Boss_inven/Info_SC")
@onready var timer: Timer = $".".get_node("/root/Run/SceneContainer/BB/Boss_inven/Phase_Timer")

@onready var health: TextureProgressBar = $".".get_node("/root/Run/SceneContainer/BB/Boss_inven/BHealth")
@onready var to_p_dmg: TextureProgressBar = $".".get_node("/root/Run/SceneContainer/BB/Boss_inven/BDMG")
@onready var to_b_dmg: TextureProgressBar = $".".get_node("/root/Run/SceneContainer/BB/Boss_inven/BSDMG")

@onready var health_lbl: Label = $".".get_node("/root/Run/SceneContainer/BB/Boss_inven/Health")
@onready var dmg_lbl: Label = $".".get_node("/root/Run/SceneContainer/BB/Boss_inven/DMG")
@onready var afforded_time: Label = $".".get_node("/root/Run/SceneContainer/BB/Boss_inven/Phase_Label")

var tw: Tween
var diff_dict = {"Easy": 1, "Normal": 2, "Hard": 3, "Extreme": 4}
var phase_dmg: int
var phase_time: int
var health_amt: int = 75 * diff_dict.get(Gamestate.difficulty)
var phase_subtract: int
var level: String
var attacks = {0: "attack2", 1: "attack3", 2: "attack4"}
# var i = 0

signal intro_done
signal filled
signal phase_complete
signal enemy_defeated
signal decreased

var is_intro: bool = true

func _ready():
	Gamestate.ability = ""
	boss.play("t_in")
	await boss.animation_finished

	text_display.visible = true
	
	health.value = 0
	health.visible = true
	health.max_value = health_amt
	to_p_dmg.value = 0
	to_p_dmg.visible = true
	to_b_dmg.value = 0
	to_b_dmg.visible = true
	
	health_lbl.visible = true
	dmg_lbl.visible = true
	afforded_time.visible = true
	
	_intro_string()
	_boss_sequence()
	

func _boss_sequence():
	# create while instead of for loop
	# while boss isn't dead keep on going
	var idx := 0
	
	while true:
		if idx <= 1:
			level = "low"
		elif idx <= 3:
			level = "mid"
		else:
			level = "high"
			
		phases(idx + 1)
		await phase_complete
		
		idx = idx + 1
		
		if health.value <= 0:
			break
		
func phases(curr_phase: int):
	_calc_phase(curr_phase)
	_fill()
	await filled
	
	if is_intro:
		await intro_done
		is_intro = false
	
	await boss.animation_looped
	boss.play("t_out")
	await boss.animation_finished
	boss.visible = false
	print(to_b_dmg.value)
	
	for i in range(curr_phase):
		battle.enemy_input(str(i), level)
		battle.enemy.sprite.modulate.a = 0.0
		battle.battle_intro()
		battle.enemy_health.visible = true
		
		await battle.begin_shown
		battle.ui_inventory.enable_buttons()
		if not timer.timeout.is_connected(_increment_timer):
			timer.timeout.connect(_increment_timer)
			
		timer.start(1.0)
		
		if battle.enemy and battle.enemy.has_signal("health_depleted"):
			battle.enemy.health_depleted.connect(func(): timer.stop(), CONNECT_ONE_SHOT)
		
		await battle.enemy.boss_enemy_done
		battle.ui_inventory.disable_buttons()
		_decrease(curr_phase)
		battle.reset_hand_after_boss_enemy()
		
	timer.stop()
	battle.clear_tray_for_boss()
	await decreased
	battle.boss_outro()
	var twin = create_tween()
	twin.parallel().tween_property(health, "value", health.value - to_b_dmg.value, 1.0)
	twin.parallel().tween_property(afforded_time, "modulate:a", 0.0, 1.0)
	twin.parallel().tween_method(fill_lbls.bind(health_lbl), health.value, health.value - to_b_dmg.value, 1.0)
	twin.parallel().tween_property(to_b_dmg, "value", 0.0, 1.0) 
	
	await twin.finished
	
	boss.visible = true
	battle.enemy_health.visible = false
	boss.play("t_in")
	# battle.tray.clear_for_boss()
	
	await boss.animation_finished
	emit_signal("phase_complete")
	
func phase_not_completed():
	timer.stop()
	
	var twin2 = create_tween()
	
	twin2.tween_property(battle.enemy.sprite, "modulate:a", 0.0, 0.6)
	
	if battle and battle.has_method("clear_battle_elements_on_screen"):
		battle.clear_battle_elements_on_screen()
	
	battle.boss_outro()
	var twin = create_tween()
	twin.parallel().tween_property(health, "value", health.value - to_b_dmg.value, 1.0)
	twin.parallel().tween_property(afforded_time, "modulate:a", 0.0, 1.0)
	twin.parallel().tween_property(to_b_dmg, "value", 0.0, 1.0) 
	twin.parallel().tween_method(fill_lbls.bind(health_lbl), health.value, health.value - to_b_dmg.value, 1.0) 
	battle.enemy_health.visible = false
	
	await twin.finished
	
	boss.visible = true
	boss.play("t_in")
	
	await boss.animation_finished
	
	if health.value <= 0:
		emit_signal("phase_complete")
		return
	
	var att = randi() % 3
	boss.play(attacks.get(att))
	
	await boss.animation_finished
	battle.player_hit(to_p_dmg.value)
	to_p_dmg.value = 0.0
	dmg_lbl.text = "0"
	
	emit_signal("phase_complete")
	
func _decrease(phase: int):
	var twin = create_tween()
	
	twin.tween_property(to_p_dmg, "value", to_p_dmg.value - phase_subtract, 2.0)
	twin.parallel().tween_property(to_b_dmg, "value", to_b_dmg.value + phase_subtract, 2.0)
	twin.parallel().tween_method(fill_lbls.bind(dmg_lbl), to_p_dmg.value, to_p_dmg.value - phase_subtract, 2.0)
	
	await twin.finished
	emit_signal("decreased")

func _fill():
	boss.play("attack1")
	var twin = create_tween()
	
	if health_lbl.text == "":
		twin.tween_property(health, "value", health_amt, 5.0)
		twin.parallel().tween_method(fill_lbls.bind(health_lbl), 0, health_amt, 5.0)
	
	twin.parallel().tween_property(to_p_dmg, "value", phase_dmg, 5.0)
	twin.parallel().tween_method(fill_lbls.bind(dmg_lbl), 0, phase_dmg, 5.0)
	
	if to_b_dmg.value != 0.0:
		twin.parallel().tween_property(to_b_dmg, "value", 0, 1.0)
	
	afforded_time.text = str(phase_time)
	afforded_time.modulate.a = 0.0
	twin.tween_property(afforded_time, "modulate:a", 1.0, 2.0)
	 
	await twin.finished
	emit_signal("filled")
	

func fill_lbls(value: int, lbl: Label):
	lbl.text = str(value)

func _intro_string():
	_display_text("This is the final battle")
	timer.start(3)
	
	await timer.timeout
	
	_display_text("The rightmost meter is the boss health, and the other meter is the damage to be dealt\n
	Defeat enemies within the time provided to decrease the damage\n
	All decreased damage becomes damage done to the boss")
	timer.start(12)
	
	await timer.timeout
	
	_display_text("The numbers below the meters display the meter amounts\n
	The number in the corner is the amount of time provided")
	timer.start(7)
	
	await timer.timeout
	
	_display_text("Good luck")
	timer.start(3)
	
	await timer.timeout
	text_display.text = ""
	
	await boss.animation_looped
	emit_signal("intro_done")
	
func _calc_phase(phase_num: int):
	phase_dmg = phase_num * 5 * diff_dict.get(Gamestate.difficulty)
	phase_time = phase_num * 10 + 2 * phase_num + 1
	to_p_dmg.max_value = phase_dmg
	to_b_dmg.max_value = phase_dmg
	phase_subtract = phase_dmg / phase_num
	
func _increment_timer():
	afforded_time.text = str(int(afforded_time.text) - 1)
	if afforded_time.text == "0":
		phase_not_completed()

func _play_idle():
	boss.play("idle")
	boss.position.y += 34
	boss.position.x -= 3
	
func _play_anim(anim: String):
	boss.position.y -= 34
	boss.position.x += 3
	boss.play(anim)
	
func _display_text(texts: String):
	if tw and tw.is_running():
		tw.kill()
	text_display.text = texts
	text_display.visible_characters = 0
	var dur = texts.length() / max(1.0, 25.0)
	tw = create_tween()
	tw.tween_property(text_display, "visible_characters", texts.length(), dur)

	
	
