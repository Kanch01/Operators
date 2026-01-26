extends Node2D

var inventory: Inventory
@onready var ui_inventory = $Hand
@onready var tray = $Tray
@onready var health = $Health
@onready var label = $Health/Label
@onready var deslow = $DeSlow
@onready var camera = $Camera2D
@onready var enemy_health = $EHealth

@onready var bleedout: ColorRect = $Bleed
@onready var miss_label: Label = $miss
@onready var grey_rect: ColorRect = $TimeStop
@onready var b_timer: Timer = $BattleTimer
@onready var begin_lb: Label = $Begin
@onready var timer_lb: Label = $BattleTimer/Label

@onready var shield: TextureProgressBar = $Shield
@onready var shield_amt: Label = $Shield/Label
@onready var invent = $Item_Inven

signal begin_shown

var enemies = {
	"0": preload("res://scenes/enemies/enemy_i.tscn"),
	"1": preload("res://scenes/enemies/enemy_a.tscn"),
	"2": preload("res://scenes/enemies/enemy_b.tscn"),
	"3": preload("res://scenes/enemies/enemy_c.tscn"),
	"4": preload("res://scenes/enemies/enemy_g.tscn"),
	"5": preload("res://scenes/enemies/enemy_h.tscn"),
	"6": preload("res://scenes/enemies/enemy_f.tscn")
}

var enemy
var boss
var mats: ShaderMaterial


var elapsed_time := 0.0
var inven_pos: float
var tray_pos: float
var health_pos: float
var shield_pos: float
var invent_pos: float

var _battle_intro_tween: Tween
var _begin_fade_tween: Tween
var _begin_scale_tween: Tween


func _ready():
	if Gamestate.tflors == Gamestate.floors:
		$".".add_child(enemies.get("6").instantiate())
		boss = $".".get_child(-1)
		boss.position.x = get_viewport_rect().size.x * 0.5 - 25
		boss.position.y = get_viewport_rect().size.y * 0.5 - 70
		enemy_health.visible = false
		timer_lb.visible = false
	else:
		enemy_selector()
		
	bleeding()
	Gamestate.last_stand_used = false
	Gamestate.sub_based = false
	if Gamestate.has_shield == true:
		replenish_shield()
		
	mats = grey_rect.material as ShaderMaterial
	mats.set_shader_parameter("amount", 0.0)
	mats.set_shader_parameter("radius", 1.0)
	mats.set_shader_parameter("feather", 0.2)
	
	miss_label.pivot_offset = miss_label.size * 0.5
	if Gamestate.ability == "Rested Soul":
		Gamestate.pstats.heal(Gamestate.pstats.max_health / 2)
		
	var tops = bleedout.material as ShaderMaterial
	tops.set_shader_parameter("top", Gamestate.blood)
	inventory = Inventory.new()
	add_child(inventory)
	
	ui_inventory.inventory = inventory
	tray.inventory = inventory
	
	inventory.draw_hand()
	
	health.max_value = Gamestate.pstats.max_health
	health.value = Gamestate.pstats.health
	label.text = str(int(Gamestate.pstats.health)) + "/" + str(int(Gamestate.pstats.max_health))

	tray.connect("expression_submitted", Callable(self, "_damaged"))
	
	# battle intro sequence
	shield_pos = shield.position.y
	invent_pos = invent.position.y
	inven_pos = ui_inventory.position.y
	tray_pos = tray.position.y
	health_pos = health.position.y
	
	ui_inventory.position.y += 212
	tray.position.y += 212
	health.position.y += 212
	shield.position.y += 212
	invent.position.y += 212
	
	begin_lb.modulate.a  = 0.0
	timer_lb.text = "00:00"
	b_timer.wait_time = 0.5
	
	if Gamestate.tflors != Gamestate.floors:
		enemy.sprite.modulate.a = 0.0
		b_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
		battle_intro()

func replenish_shield():
	shield.visible = true
	shield.value = 3
	shield_amt.text = "3/3"
	Gamestate.pstats.shield = 3
	
func boss_outro():
	var tw = create_tween()
	tw.tween_property(ui_inventory, "position:y", ui_inventory.position.y + 212, 0.2)
	if shield.visible == true:
		tw.tween_property(shield, "position:y", shield.position.y + 212, 0.2)
	tw.tween_property(tray, "position:y", tray.position.y + 212, 0.2)
	tw.tween_property(health, "position:y", health.position.y + 212, 0.2)
	if Gamestate.consumable or Gamestate.passive_item_inventory != [{}, {}]:
		tw.tween_property(invent, "position:y", invent.position.y + 212, 0.2)
		
	await tw.finished

func battle_intro():
	if _battle_intro_tween and _battle_intro_tween.is_running():
		_battle_intro_tween.kill()
		
	var tw = create_tween()
	_battle_intro_tween = tw
	
	tw.tween_interval(1.0)
	
	tw.tween_property(ui_inventory, "position:y", inven_pos, 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if shield.visible == true:
		tw.tween_property(shield, "position:y", shield_pos, 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tw.tween_property(tray, "position:y", tray_pos, 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(health, "position:y", health_pos, 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	if Gamestate.consumable or Gamestate.passive_item_inventory != [{}, {}]:
		tw.tween_property(invent, "position:y", invent_pos, 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tw.tween_interval(0.5)
	tw.tween_property(enemy.sprite, "modulate:a", 1.0, 0.6)
	
	tw.tween_callback(_show_begin_text)
	if Gamestate.tflors != Gamestate.floors:
		tw.tween_callback(_start_battle_timer)
	
func _show_begin_text():
	begin_lb.pivot_offset = begin_lb.size * 0.5
	
	if _begin_fade_tween and _begin_fade_tween.is_running():
		_begin_fade_tween.kill()
	if _begin_scale_tween and _begin_scale_tween.is_running():
		_begin_scale_tween.kill()
	
	var t = create_tween()
	var tt = create_tween()
	
	_begin_fade_tween = t
	_begin_scale_tween = tt
	
	t.tween_property(begin_lb, "modulate:a", 1.0, 0.3)
	tt.tween_property(begin_lb, "scale", Vector2(1.3, 1.3), 0.3)
	t.tween_interval(0.5)
	t.tween_property(begin_lb, "modulate:a", 0.0, 0.3)
	
	await t.finished
	emit_signal("begin_shown")
	
func _start_battle_timer():
	b_timer.start()
	enemy.start_etimer()
	ui_inventory.enable_buttons()

func _on_timer_timeout():
	elapsed_time += b_timer.wait_time
	var mins = int(elapsed_time) / 60
	var secs = int(elapsed_time) % 60
	timer_lb.text = "%02d:%02d" % [mins, secs]

func _damaged(res: int):
	if Gamestate.sacrifice == true:
		player_hit(res)
		enemy.other_damage(res)
	elif Gamestate.sub_based == true:
		enemy.other_damage(res)
	else:
		if enemy.stats.health % res != 0:
			return
		enemy.take_damage(res)
	
	if enemy.stats.health == 0:
		if elapsed_time <= 7.0:
			Gamestate.quick_takedown = true
		else:
			Gamestate.quick_takedown = false
			
		if elapsed_time <= 15.0 and Gamestate.money_up == true:
			Gamestate.extra_muns = true
		else:
			Gamestate.extra_muns = false
		

func win_screen():
	# realistically win_screen would be made by some pool alg
	ui_inventory.disable_buttons()
	tray.disable_submit()
	
	$".".add_child(preload("res://scenes/WinScreen.tscn").instantiate())
	var visual = $Hold/Screen
	visual.position.x = get_viewport_rect().size.x * 0.5 - (visual.size.x / 2)
	visual.position.y = get_viewport_rect().size.y * 0.5 - (visual.size.y / 2) - 50

func nextin():
	var next = get_tree().root
	next.get_node("Run").show_scene("map")
		
func enemy_selector():
	if Gamestate.floors == 15:
		Gamestate.ediff = "boss"
		enemy_input("6", "boss")
	elif Gamestate.floors <= 2:
		Gamestate.ediff = "low"
		enemy_input("0", "low")
	elif Gamestate.floors <= 9:
		var number: int = randi_range(1, 3)
		Gamestate.ediff = "mid"
		enemy_input(str(number), "mid")
	else:
		var number: int = randi_range(4, 5)
		Gamestate.ediff = "high"
		enemy_input(str(number), "high")
		
func enemy_input(key: String, tier: String):
	$".".add_child(enemies.get(key).instantiate())
	enemy = $".".get_child(-1)
	# change pos to be higher, but works, will change for many
	enemy.position.x = get_viewport_rect().size.x * 0.5
	enemy.position.y = get_viewport_rect().size.y * 0.5 - 100
	var stats = Stats.new()
	
	var hp_range = Gamestate.enemies.get(tier).get("range")
	
	stats.max_health = _set_enemy_health(hp_range, Gamestate.difficulty, tier)
	
	enemy.set_enemy_stats(stats)
	# enemy.stats.shield = 0
	
func _set_enemy_health(rang: Array, diff: String, tier: String):
	var hp
	if diff == "Easy":
		hp = 1
		while hp % 2 != 0:
			hp = randi_range(rang[0], rang[1])
	elif diff == "Normal":
		if tier == "low":
			hp = 1
			while hp % 2 != 0:
				hp = randi_range(rang[0], rang[1])
		elif tier == "mid":
			hp = randi_range(rang[0], rang[1])
		else:
			hp = 2
			while hp % 2 == 0:
				hp = randi_range(rang[0], rang[1])
	elif diff == "Hard":
		if tier == "low":
			hp = randi_range(rang[0], rang[1])
		else:
			hp = 2
			while hp % 2 == 0:
				hp = randi_range(rang[0], rang[1])
	else:
		hp = 2
		while hp % 2 == 0:
			hp = randi_range(rang[0], rang[1])
			
	return hp
	
func bleeding():
	var matis = bleedout.material as ShaderMaterial
	
	Gamestate.multiplier = 1.2 - ((float(Gamestate.pstats.health) / float(Gamestate.pstats.max_health)) * 1.2)
	matis.set_shader_parameter("top", Gamestate.multiplier)
	Gamestate.blood = Gamestate.multiplier
	
func player_hit(dmg):
	var miss: int = randi() % 7
	if Gamestate.ability != "Leisurely Parry":
		miss = -1
	if miss == 1:
		show_miss_text("MISS")
		return
	
	if Gamestate.last_stand == true and Gamestate.last_stand_used == false and Gamestate.pstats.health + Gamestate.pstats.shield - dmg <= 0:
		Gamestate.pstats.health = 1
		Gamestate.last_stand_used = true
	else:
		Gamestate.pstats.take_damage(dmg, "player")
		
	bleeding()
	
	deslow.pulse_desaturation()
	deslow.slow_mo()
	camera.shake(0.2, 6)
	
	health.value = Gamestate.pstats.health
	label.text = str(int(health.value)) + "/" + str(int(health.max_value))
	shield.value = 0
	shield_amt.text = "0/0"
	
	if Gamestate.ability == "Eternal Clock" and Gamestate.pstats.health > 0:
		if Gamestate.pstats.health + Gamestate.pstats.shield - enemy.output <= 0:
			vignette()
		else:
			enemy.sprite.play("idle")
	else:
		if enemy:
			enemy.sprite.play("idle")


func show_miss_text(text: String) -> void:
	miss_label.text = text
	miss_label.visible = true
	
	miss_label.scale = Vector2(0.5, 0.5)
	miss_label.modulate.a = 1.0
	
	var tw = create_tween()
	
	tw.tween_property(miss_label, "scale", Vector2(1.5, 1.5), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(miss_label, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	tw.connect("finished", Callable(self, "_on_miss_tween_finished"))

func _on_miss_tween_finished():
	miss_label.visible = false
	
func vignette(duration := 3):
	enemy.sprite.stop()
	enemy.timer.paused = true
	
	mats.set_shader_parameter("amount", 1.0)
	mats.set_shader_parameter("radius", mats.get_shader_parameter("feather"))
	var tw = create_tween()
	tw.tween_property(mats, "shader_parameter/radius", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await tw.finished
	
	var tw2 = create_tween()
	tw2.tween_property(mats, "shader_parameter/radius", mats.get_shader_parameter("feather"), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tw2.finished
	
	enemy.timer.paused = false
	enemy.sprite.play("idle")
	
func reset_hand_after_boss_enemy():
	tray.clear_for_boss()
	inventory.reset_full_hand()
	ui_inventory.draw_hand()
	ui_inventory.disable_buttons()
	
func clear_tray_for_boss():
	tray.clear_for_boss()
	
func clear_battle_elements_on_screen() -> void:
	# Called by the boss script when a phase ends abruptly (e.g., timer runs out)
	# to ensure no enemy/UI animation keeps running in the background.

	# Stop any in-progress intro/begin animations so they don't "re-show" an enemy.
	if _battle_intro_tween and _battle_intro_tween.is_running():
		_battle_intro_tween.kill()
	if _begin_fade_tween and _begin_fade_tween.is_running():
		_begin_fade_tween.kill()
	if _begin_scale_tween and _begin_scale_tween.is_running():
		_begin_scale_tween.kill()

	begin_lb.modulate.a = 0.0

	# Disable input and clear the tray expression/results.
	if ui_inventory:
		ui_inventory.disable_buttons()

	if tray:
		if tray.has_method("clear_for_boss"):
			tray.clear_for_boss()
		if tray.has_node("Result"):
			tray.get_node("Result").text = ""
		if tray.has_node("Expression"):
			tray.get_node("Expression").text = ""
		if tray.has_method("disable_submit"):
			tray.disable_submit()

	# Hide enemy health UI.
	if enemy_health:
		enemy_health.visible = false
		enemy_health.value = 0
		if enemy_health.get_child_count() > 0 and enemy_health.get_child(0) is Label:
			enemy_health.get_child(0).text = "0/0"

	# Remove any active enemy nodes from the scene so nothing stays on screen.
	# (Boss itself is NOT an Enemy class, so it won't be removed here.)
	for child in get_children():
		if child is Enemy:
			child.queue_free()

	enemy = null
