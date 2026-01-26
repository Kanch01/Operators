extends Node

var characters = {
	"cat": [44, "Eternal Clock"],
	"tiger": [50, "Rapid Strike"],
	"panda": [56, "Leisurely Parry"],
	"axolotl": [38, "Rested Soul"]
}

var enemies = {
	"low": {"time": 0, "dmg": 0, "range": [], "status_odds": 0}, 
	"mid": {"time": 0, "dmg": 0, "range": [], "status_odds": 0}, 
	"high": {"time": 0, "dmg": 0, "range": [], "status_odds": 0}
}

var ITEMS = {
	0: {"sell_function": Callable(self, "take_shield"), "key": 0, "function": Callable(self, "give_shield"), "name": "Shield", "cost": 300, "owned": false, "passive": true, "effect": "Gives 3 shield permanently, regenerates after every battle", "path": "res://assets/to_use/fc857.png"},
	1: {"key": 1, "function": Callable(self, "meddi_beddi"), "name": "Porta Heal", "cost": 1000, "owned": false, "passive": false, "effect": "Completely restores health, can be used at anytime when in battle (single use)", "path": "res://assets/to_use/fc93.png"},
	2: {"sell_function": Callable(self, "health_down"), "key": 2, "function": Callable(self, "health_up"), "name": "Health UP", "cost": 500, "owned": false, "passive": true, "effect": "Increases health and max health by 10, will have opposite effect if sold", "path": "res://assets/to_use/fc868.png"},
	3: {"key": 3, "function": Callable(self, "perf_split"), "name": "Perfect Split", "cost": 700, "owned": false, "passive": false, "effect": "Halves enemy HP, rounds down if HP is odd (single use)", "path": "res://assets/to_use/fc863.png"},
	4: {"sell_function": Callable(self, "ones"), "key": 4, "function": Callable(self, "akimbo"), "name": "Akimbo", "cost": 800, "owned": false, "passive": true, "effect": "If the number one is owned, player can input a single digit number immediately after it", "path": "res://assets/to_use/fc1757.png"},
	5: {"sell_function": Callable(self, "dexpeonent"), "key": 5, "function": Callable(self, "exponential"), "name": "Double Cross", "cost": 1250, "owned": false, "passive": true, "effect": "Can raise a number to a power by using two consecutive multiplication signs (ex: 4 ** 2 = 16)", "path": "res://assets/to_use/fc730.png"},
	6: {"sell_function": Callable(self, "money_down"), "key": 6, "function": Callable(self, "munyun"), "name": "Time is Money", "cost": 1000, "owned": false, "passive": true, "effect": "Defeating enemy within 15s gives 350 coins", "path": "res://assets/to_use/fc190.png"},
	7: {"sell_function": Callable(self, "no_roll"), "key": 7, "function": Callable(self, "rerolling"), "name": "Lucky Roll", "cost": 800, "owned": false, "passive": true, "effect": "Allows for shop items to be rerolled for 250 coins, increases for every consecutive reroll", "path": "res://assets/to_use/fc294.png"},
	8: {"sell_function": Callable(self, "single_clear"), "key": 8, "function": Callable(self, "mrhands"), "name": "Helping Hand", "cost": 1750, "owned": false, "passive": true, "effect": "Deals new hand, use by quickly double-clicking 'CLEAR'", "path": "res://assets/to_use/fc1648.png"},
	9: {"key": 9, "function": Callable(self, "gotmilk"), "name": "Milk", "cost": 300, "owned": false, "passive": false, "effect": "Prevent statuses for 15 seconds (single use)", "path": "res://assets/to_use/fc92.png"},
	10: {"sell_function": Callable(self, "disabled"), "key": 10, "function": Callable(self, "urshifu"), "name": "Single Strike", "cost": 1500, "owned": false, "passive": true, "effect": "If enemy is one shot, increase max health by 5", "path": "res://assets/to_use/fc734.png"},
	11: {"key": 11, "function": Callable(self, "evens"), "name": "Stevens", "cost": 600, "owned": false, "passive": false, "effect": "Make enemy HP even (single use)", "path": "res://assets/to_use/fc332.png"},
	12: {"sell_function": Callable(self, "knocked"), "key": 12, "function": Callable(self, "endurance"), "name": "Still Standing", "cost": 1500, "owned": false, "passive": true, "effect": "Player survives on 1 HP if player would've lost otherwise", "path": "res://assets/to_use/fc398.png"},
	13: {"sell_function": Callable(self, "no_vamp"), "key": 13, "function": Callable(self, "one_more"), "name": "Draining Hit", "cost": 800, "owned": false, "passive": true, "effect": "When used, all player damage will be subtracted from enemy and player health", "path": "res://assets/to_use/fc986.png"},
	14: {"key": 14, "function": Callable(self, "subway"), "name": "Subs", "cost": 1000, "owned": false, "passive": false, "effect": "Makes battle subtraction based, not division based (single use)", "path": "res://assets/to_use/fc2123.png"}
}

var perma_numbers = []

# Ability variables
var has_shield = false
var is_split = false
var exponentials = false
var money_up = false
var extra_muns = false
var reroll = false
var rerollamt = 250
var one_shot = false
var last_stand = false
var last_stand_used = false
var sacrifice = false
var sub_based = false
var double_clear = false
var two_nums = false
var got_milk = false
# end of variables

var passive_item_inventory = [{}, {}]
var consumable
var multiplier

var quick_takedown: bool = false

var pstats: Stats
var ability: String
var map_data: Array[Array]
var curr_room: Room
var bag = []
var floors: int = 0
var chealth: int
var cshield: int
var tflors: int = 15 # originally 15
var blood: float = 0.0
var difficulty: String

var ediff: String
var muns: int = 0

func give_shield():
	has_shield = true
	
func take_shield():
	has_shield = false
	
func meddi_beddi():
	pstats.heal(100)
	
func health_up():
	pstats.max_health += 10
	pstats.heal(10)

func health_down():
	pstats.max_health -= 10
	if pstats.health <= 10:
		# later change for game over screen
		var par = get_tree().root
		par.get_node("Run").show_scene("main_menu")
	else:
		pstats.health -= 10

func perf_split():
	pass
	
func akimbo():
	two_nums = true
	
func ones():
	two_nums = false
	
func exponential():
	exponentials = true
	
func dexpeonent():
	exponentials = false
	
func munyun():
	money_up = true
	
func money_down():
	extra_muns = false
	money_up = false
	
func rerolling():
	reroll = true
	
func no_roll():
	reroll = false
	
func mrhands():
	double_clear = true
	
func single_clear():
	double_clear = false
	
func gotmilk():
	got_milk = true
	
func urshifu():
	one_shot = true
	
func disabled():
	one_shot = false
	
func evens():
	pass
	
func endurance():
	last_stand = true
	
func knocked():
	last_stand = false
	
func one_more():
	pass
	
func no_vamp():
	pass
	
func subway():
	pass

func reset():
	map_data.clear()
	bag.clear()
	curr_room = null
	floors = 0
	chealth = 0
	cshield = 0
	passive_item_inventory = [{}, {}]
	consumable = null
	quick_takedown = false
	ability = ""
	bag = []
	blood = 0.0
	muns = 0
	multiplier = 0
	
func create_play(chare: String):
	pstats = Stats.new()
	pstats.max_health = characters.get(chare)[0]
	pstats.shield = 0
	pstats.health = characters.get(chare)[0]
	ability = characters.get(chare)[1]
	
