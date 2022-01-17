extends Node2D
var Units = []

# Export and store these in the Unit?
var SelectedUnitState = null
# Unit state will determine if unit can act
# Idle plays the idle animation and lets the unit take any action
# Busy will be a temp state that stops it from acting in say cutscenes or movement, maintains current anim
var CombatState = null
# Combat state determines which actions a unit can take
# Ready means a unit can perform any action
# Exhausted means they cannot perform any more actions this turn, triggered by attacking
# Tired means unit has moved meaning they can no longer  

func _ready():
	UpdateUnits()


# So what I'm planning here is to get the attacks from the units, pass it to the tilemap for pathing
# then plug the damage into attack.


func Attack(Attacker, Defender):
	var damage = get_attack_info(Attacker)
	Defender.receive_damage(damage)

# MicroFunctions

func UpdateUnits():
	 Units = get_children()

func get_attack_info(unit):
	return unit.export_attack_info()

