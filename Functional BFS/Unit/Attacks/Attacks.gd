extends Resource
class_name Attacks

export(String) var attack_name
export(int) var damage = 5
export(Array, Vector2) var targeted_tiles = [Vector2(0,0)]
export(Array, String) var special_effects = ["None"]
