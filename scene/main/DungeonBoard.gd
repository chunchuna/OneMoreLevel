extends Node2D
class_name Game_DungeonBoard


var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()

# <main_group: String, <column: int, [sprite]>>
var _sprite_dict: Dictionary

var _valid_main_groups: Array = [
	_new_MainGroupTag.GROUND,
	_new_MainGroupTag.ACTOR,
	_new_MainGroupTag.BUILDING,
	_new_MainGroupTag.TRAP,
]

var _sub_group_to_sprite: Dictionary = {
	_new_SubGroupTag.ARROW_LEFT: null,
	_new_SubGroupTag.ARROW_TOP: null,
	_new_SubGroupTag.ARROW_BOTTOM: null,
}


func _ready() -> void:
	_init_dict()


func has_sprite(main_group: String, x: int, y: int) -> bool:
	if not _new_CoordCalculator.is_inside_dungeon(x, y):
		return false
	if not _sprite_dict.has(main_group):
		return false
	if not _sprite_dict[main_group].has(x):
		return false
	return _sprite_dict[main_group][x][y] != null


func get_sprite(main_group: String, x: int, y: int) -> Sprite:
	if has_sprite(main_group, x, y):
		return _sprite_dict[main_group][x][y]
	return null


func move_sprite(main_group: String, source: Array, target: Array) -> void:
	var sprite: Sprite = get_sprite(main_group, source[0], source[1])
	if sprite == null:
		return

	_sprite_dict[main_group][source[0]][source[1]] = null
	_sprite_dict[main_group][target[0]][target[1]] = sprite
	sprite.position = _new_ConvertCoord.index_to_vector(target[0], target[1])

	_try_move_arrow(sprite)


func swap_sprite(main_group: String, source: Array, target: Array) -> void:
	var source_sprite: Sprite = get_sprite(main_group, source[0], source[1])
	var target_sprite: Sprite = get_sprite(main_group, target[0], target[1])

	if (source_sprite == null) or (target_sprite == null):
		return

	_sprite_dict[main_group][source[0]][source[1]] = target_sprite
	_sprite_dict[main_group][target[0]][target[1]] = source_sprite

	source_sprite.position = _new_ConvertCoord.index_to_vector(
			target[0], target[1])
	target_sprite.position = _new_ConvertCoord.index_to_vector(
			source[0], source[1])

	_try_move_arrow(source_sprite)
	_try_move_arrow(target_sprite)


func _on_CreateObject_sprite_created(new_sprite: Sprite) -> void:
	var pos: Array
	var group: String

	# Save references to arrow indicators.
	if new_sprite.is_in_group(_new_MainGroupTag.INDICATOR):
		for sg in _sub_group_to_sprite.keys():
			if new_sprite.is_in_group(sg):
				_sub_group_to_sprite[sg] = new_sprite
		return

	# Save references to dungeon sprites.
	for mg in _valid_main_groups:
		if new_sprite.is_in_group(mg):
			group = mg
			break
	if group == "":
		return
	pos = _new_ConvertCoord.vector_to_array(new_sprite.position)
	_sprite_dict[group][pos[0]][pos[1]] = new_sprite


func _on_RemoveObject_sprite_removed(_sprite: Sprite, main_group: String,
		x: int, y: int) -> void:
	_sprite_dict[main_group][x][y] = null


func _init_dict() -> void:
	for mg in _valid_main_groups:
		_sprite_dict[mg] = {}
		for x in range(_new_DungeonSize.MAX_X):
			_sprite_dict[mg][x] = []
			_sprite_dict[mg][x].resize(_new_DungeonSize.MAX_Y)


# Move arrow indicators when PC moves.
func _try_move_arrow(sprite: Sprite) -> void:
	if not sprite.is_in_group(_new_SubGroupTag.PC):
		return

	_sub_group_to_sprite[_new_SubGroupTag.ARROW_LEFT] \
			.position.y = sprite.position.y
	_sub_group_to_sprite[_new_SubGroupTag.ARROW_TOP] \
			.position.x = sprite.position.x
	_sub_group_to_sprite[_new_SubGroupTag.ARROW_BOTTOM] \
			.position.x = sprite.position.x
