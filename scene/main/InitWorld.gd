extends Node2D


signal sprite_created(new_sprite)

const Player := preload("res://sprite/PC.tscn")
const Dwarf := preload("res://sprite/Dwarf.tscn")
const Floor := preload("res://sprite/Floor.tscn")
const Wall := preload("res://sprite/Wall.tscn")
const ArrowX := preload("res://sprite/ArrowX.tscn")
const ArrowY := preload("res://sprite/ArrowY.tscn")
const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")
const RandomNumber := preload("res://scene/main/RandomNumber.gd")

const InitDemo := preload("res://scene/init/InitDemo.tscn")

var _ref_DungeonBoard: DungeonBoard
var _ref_RandomNumber: RandomNumber

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_GroupName := preload("res://library/GroupName.gd").new()
var _new_InputName := preload("res://library/InputName.gd").new()

var _world: Node


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(_new_InputName.INIT_WORLD):
		_init_floor()
		_init_wall()
		_init_PC()
		_init_dwarf()
		_init_indicator()

		_world = _select_world()
		_set_world_reference(_world)
		add_child(_world)
		var __ = _world.get_blueprint()

		set_process_unhandled_input(false)


func _select_world() -> Node:
	var candidate: Node
	candidate = InitDemo.instance()

	return candidate


func _set_world_reference(new_world: Node) -> void:
	var __ = new_world
	return


func _init_dwarf() -> void:
	var dwarf: int = _ref_RandomNumber.get_int(3, 6)
	var x: int
	var y: int

	while dwarf > 0:
		x = _ref_RandomNumber.get_int(1, _new_DungeonSize.MAX_X - 1)
		y = _ref_RandomNumber.get_int(1, _new_DungeonSize.MAX_Y - 1)

		if _ref_DungeonBoard.has_sprite(_new_GroupName.WALL, x, y) \
				or _ref_DungeonBoard.has_sprite(_new_GroupName.DWARF, x, y):
			continue
		_create_sprite(Dwarf, _new_GroupName.DWARF, x, y)
		dwarf -= 1


func _init_PC() -> void:
	_create_sprite(Player, _new_GroupName.PC, 0, 0)


func _init_floor() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			_create_sprite(Floor, _new_GroupName.FLOOR, i, j)


func _init_wall() -> void:
	var shift: int = 2
	var min_x: int = _new_DungeonSize.CENTER_X - shift
	var max_x: int = _new_DungeonSize.CENTER_X + shift + 1
	var min_y: int = _new_DungeonSize.CENTER_Y - shift
	var max_y: int = _new_DungeonSize.CENTER_Y + shift + 1

	for i in range(min_x, max_x):
		for j in range(min_y, max_y):
			_create_sprite(Wall, _new_GroupName.WALL, i, j)


func _init_indicator() -> void:
	_create_sprite(ArrowX, _new_GroupName.ARROW, 0, 12,
			-_new_DungeonSize.ARROW_MARGIN)
	_create_sprite(ArrowY, _new_GroupName.ARROW, 5, 0,
			0, -_new_DungeonSize.ARROW_MARGIN)


func _create_sprite(prefab: PackedScene, group: String, x: int, y: int,
		x_offset: int = 0, y_offset: int = 0) -> void:

	var new_sprite: Sprite = prefab.instance() as Sprite
	new_sprite.position = _new_ConvertCoord.index_to_vector(
			x, y, x_offset, y_offset)
	new_sprite.add_to_group(group)

	add_child(new_sprite)
	emit_signal("sprite_created", new_sprite)
