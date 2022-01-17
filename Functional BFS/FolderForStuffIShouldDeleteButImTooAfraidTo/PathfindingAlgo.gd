extends TileMap
# Main Author Nico
# Az Contributor and writer

# Tilemap Variables
var Grid = get_used_cells()
var Mouse_pos = Vector2.ZERO
var SelectedTileResetValue = 0

# Node References
onready var MovementMap = $MovementMap
onready var Movement = $UnitManager/Unit.MovementExport()
onready var Unit = $UnitManager/Unit

# Dictionaries
var DictionaryBFS = {}
var DictionaryTile = {1: 1, 3: 0, 2: 4} 
var UnitLocation = {}

# Unit Logic
var SelectedCharacter = null
var UnitGroupMembers = []
var UnitsGrid = []

func _process(_delta):
	# Maybe Get Accessible to update on ready and move, not frame
	UpdateAccessibleCells()
	MouseInteraction()

func UpdateAccessibleCells():
	MovementMap.clear()
	for i in DictionaryBFS:
		if DictionaryBFS[i] <= Movement:
			MovementMap.set_cell(i.x, i.y, 1)

func MouseInteraction():
	if Input.is_action_just_pressed("Left_Click"):
		Mouse_pos = world_to_map(get_global_mouse_position())
		if Grid.has(Mouse_pos):
			if DictionaryBFS.empty():
				if (UnitLocation.values()).has(Mouse_pos):
					GetCharacterOnTile(Mouse_pos)
					GetUnitsGrid()
					MouseClick(Mouse_pos)
			elif MovementMap.get_used_cells().has(Mouse_pos):
				if not UnitLocation.values().has(Mouse_pos):
					SelectedCharacter.position = map_to_world(Mouse_pos)
					UnitLocation[SelectedCharacter] = Mouse_pos
				DictionaryBFS = {}
				UnitsGrid = []
				SelectedCharacter = null
			else: 
				DictionaryBFS = {}
				UnitsGrid = []
				SelectedCharacter = null

func GetCharacterOnTile(ClickLocation):
	for i in UnitLocation:
		if ClickLocation == UnitLocation[i]:
			SelectedCharacter = i

func GetUnitsGrid():
	for i in Grid:
		if abs(i.x) < UnitLocation[SelectedCharacter].x -+ Movement:
			if abs(i.y) < UnitLocation[SelectedCharacter].y -+ Movement:
				UnitsGrid.append(i)

func MouseClick(input):
	SelectedTileResetValue = get_cell(input.x, input.y)
	set_cell(UnitLocation[SelectedCharacter].x, UnitLocation[SelectedCharacter].y, 3)
	DictionaryBFS = {}
	BFS(input, 0)
	set_cell(UnitLocation[SelectedCharacter].x, UnitLocation[SelectedCharacter].y, SelectedTileResetValue)

func _ready():
	var UnitGroup = get_tree().get_nodes_in_group("Units")
	for i in UnitGroup:
		UnitLocation[i] = world_to_map(i.position)

func BFS(current_cell, cell_value_from_prev):
	if not UnitsGrid.has(current_cell):
		return
	var current_value = cell_value_from_prev + get_tile_weight(current_cell)
	if DictionaryBFS.has(current_cell):
		if (DictionaryBFS[current_cell]) > current_value:
			DictionaryBFS[current_cell] = current_value
	else: 
		DictionaryBFS[current_cell] = current_value
	NeighbourBFS(current_cell, current_value)

func get_tile_weight(cell_value):
	return(DictionaryTile[get_cellv(cell_value)])

func NeighbourBFS(current_cell, current_value):
	if DictionaryBFS.has(current_cell - Vector2.RIGHT):
		if DictionaryBFS[current_cell - Vector2.RIGHT] > DictionaryBFS[current_cell]:
			BFS(current_cell - Vector2.RIGHT, current_value)
	else: BFS(current_cell - Vector2.RIGHT, current_value)
	if DictionaryBFS.has(current_cell - Vector2.LEFT):
		if DictionaryBFS[current_cell - Vector2.LEFT] > DictionaryBFS[current_cell]:
			BFS(current_cell - Vector2.LEFT, current_value)
	else: BFS(current_cell - Vector2.LEFT, current_value)
	if DictionaryBFS.has(current_cell - Vector2.UP):
		if DictionaryBFS[current_cell - Vector2.UP] > DictionaryBFS[current_cell]:
			BFS(current_cell - Vector2.UP, current_value)
	else: BFS(current_cell - Vector2.UP, current_value)
	if DictionaryBFS.has(current_cell - Vector2.DOWN):
		if DictionaryBFS[current_cell - Vector2.DOWN] > DictionaryBFS[current_cell]:
			BFS(current_cell - Vector2.DOWN, current_value)
	else: BFS(current_cell - Vector2.DOWN, current_value)

#func NeighbourBFS(current_cell, current_value):
#	if DictionaryBFS.has(current_cell - Vector2.RIGHT):
#		#This one
#		if (current_cell - Vector2.RIGHT).x < current_cell.x + Movement:
#			if DictionaryBFS[current_cell - Vector2.RIGHT] > DictionaryBFS[current_cell]:
#				BFS(current_cell - Vector2.RIGHT, current_value)
#	else: BFS(current_cell - Vector2.RIGHT, current_value)
#	if DictionaryBFS.has(current_cell - Vector2.LEFT):
#			#This one
#		if (current_cell - Vector2.LEFT).x < current_cell.x - Movement:
#			if DictionaryBFS[current_cell - Vector2.LEFT] > DictionaryBFS[current_cell]:
#				BFS(current_cell - Vector2.LEFT, current_value)
#	else: BFS(current_cell - Vector2.LEFT, current_value)
#	if DictionaryBFS.has(current_cell - Vector2.UP):
#		#This one
#		if (current_cell - Vector2.UP).y < current_cell.y + Movement:
#			if DictionaryBFS[current_cell - Vector2.UP] > DictionaryBFS[current_cell]:
#				BFS(current_cell - Vector2.UP, current_value)
#	else: BFS(current_cell - Vector2.UP, current_value)
#	if DictionaryBFS.has(current_cell - Vector2.DOWN):
#		#This one
#		if (current_cell - Vector2.DOWN).y < current_cell.y - Movement:
#			if DictionaryBFS[current_cell - Vector2.DOWN] > DictionaryBFS[current_cell]:
#				BFS(current_cell - Vector2.DOWN, current_value)
#	else: BFS(current_cell - Vector2.DOWN, current_value)
