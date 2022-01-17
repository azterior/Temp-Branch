extends TileMap

# Tilemap Variables
var Mouse_pos = Vector2.ZERO
onready var Heatmap = $MovementMap
# Dictionaries
var DictionaryBFS = {}
var DictionaryTile = {1: 1, 2: 4, -1: 99} 
var TransferDict = {}
var UnitLocation = {}
# Character Vars
var Movement = 0
var RelativeGrid = []
var SelectedCharacter = null
# Temp vars attack testing
var AttackRange = 2

# Find way to remove characters occupied tiles from pathfinding then check after
# to see if they can be attacked? I'm going ballistic, cant pass through allies!

func _ready():
	UpdateCharacterLocations()

func _process(_delta):
	if Input.is_action_just_pressed("Left_Click"):
		Clicked()

func Clicked():
	Heatmap.clear()
	Mouse_pos = world_to_map(get_global_mouse_position())

	# Select Character
	if SelectedCharacter == null:
		GetRelativeGrid(Mouse_pos)
		if UnitLocation.values().has(Mouse_pos):
			GetCharacterOnTile(Mouse_pos)
			GetCharacterMovement()
			DictionaryBFS = movement_options_from(Mouse_pos, 0)

#			Debug counting cells
#			for i in DictionaryBFS:
#				Heatmap.set_cell(i.x, i.y, DictionaryBFS[i] - 1)

			for i in DictionaryBFS:
				if DictionaryBFS[i] <= Movement:
					Heatmap.set_cell(i.x, i.y, 1)
				else:
					if DictionaryBFS[i] < (Movement + AttackRange + 1):
						Heatmap.set_cell(i.x, i.y, 0)

	# Move Character
	elif DictionaryBFS.has(Mouse_pos) and not UnitLocation.values().has(Mouse_pos):
		if DictionaryBFS[Mouse_pos] <= Movement:
			SelectedCharacter.position = map_to_world(Mouse_pos)
			UpdateCharacterLocations()
			SelectedCharacter = null
		else: SelectedCharacter = null

	# Initiate Attack?
	elif DictionaryBFS.has(Mouse_pos) and UnitLocation.values().has(Mouse_pos):
		if DictionaryBFS[Mouse_pos] <= Movement + AttackRange:
			if world_to_map(SelectedCharacter.position) == Mouse_pos:  
				SelectedCharacter = null
			else:
				var defender = null
				for i in UnitLocation:
					if UnitLocation[i] == Mouse_pos:
						defender = i
				$UnitManager.Attack(SelectedCharacter, defender)
				SelectedCharacter = null
		else: SelectedCharacter = null

	# Deselect Character
	else: 
		SelectedCharacter = null

func movement_options_from(origin: Vector2, _movement_points: int) -> Dictionary:
	var shortest_distances = { origin: 0 }
	var queue = [origin]
	var distance_to_neighbor = 0
	ClearDictionaries()
	UpdateCharacterLocations()

	while not queue.empty():
		var cell := queue.pop_front() as Vector2
		var distance_to_cell = shortest_distances[cell]

		if distance_to_cell > (Movement + AttackRange): continue

		for offset in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
			var neighbor = cell + offset
			if get_cellv(neighbor) == -1: continue

			# Here we find the distance to the cell, when the unit can no longer move
			# the next AttackRange # of tiles are counted only for atacks
			distance_to_neighbor = shortest_distances[cell] + get_tile_weight(neighbor)

			# Body Blocking
			if shortest_distances[cell] < Movement:
				if UnitLocation.values().has(cell):
					if not cell == world_to_map(SelectedCharacter.position):
						shortest_distances[cell] = Movement + 1
						print(cell, distance_to_neighbor)

			# Attack areas ignore tile weight
			if distance_to_neighbor > Movement:
				if shortest_distances[cell] < Movement:
					distance_to_neighbor = Movement + 1
				else: distance_to_neighbor = shortest_distances[cell] + 1



			if not shortest_distances.has(neighbor) or shortest_distances[neighbor] > distance_to_neighbor:
				shortest_distances[neighbor] = distance_to_neighbor
				queue.push_back(neighbor)

	return shortest_distances

func GetRelativeGrid(Origin):
	RelativeGrid = [Origin]
	for x in range(-Movement + 1 + AttackRange, Movement):
		for y in range(-Movement + 1 + AttackRange, Movement):
			RelativeGrid.append(Vector2(x, y) + Origin)
	for i in RelativeGrid:
		if get_cell(i.x, i.y) == -1:
			RelativeGrid.erase(i)

# MicroFunctions

func UpdateCharacterLocations():
	var UnitGroup = get_tree().get_nodes_in_group("Units")
	for i in UnitGroup:
		UnitLocation[i] = world_to_map(i.position)

func GetCharacterOnTile(ClickLocation):
	for i in UnitLocation:
		if ClickLocation == UnitLocation[i]:
			SelectedCharacter = i

func get_tile_weight(cell_value):
	return(DictionaryTile[get_cellv(cell_value)])

func ClearDictionaries():
	DictionaryBFS = {}
	TransferDict = {}

func GetCharacterMovement():
	Movement = SelectedCharacter.MovementExport()
