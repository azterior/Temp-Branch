extends Sprite

onready var class_data = preload("res://Unit/Classes/TestClass.tres")

var Movement = 0
var health = 0
var damage = 0
var morale = 0

func MovementExport():
	return Movement

func _ready():
	add_to_group ("Units")

	# This is how I call class info
	set_health   (class_data)
	set_movement (class_data)
	set_damage   (class_data)
	set_morale   (class_data)

func receive_damage(damage_value):
	health -= damage_value
	print(health)

func export_attack_info():
	return damage

func set_health(data):
	health = data.health

func set_movement(data):
	Movement = data.movement

func set_damage(data):
	damage = data.damage

func set_morale(data):
	morale = data.morale
