extends Node2D


const ObjectData := preload("res://scene/main/ObjectData.gd")

var _ref_ObjectData: ObjectData


func switch_sprite(sprite: Sprite, type_tag: String) -> void:
	var current_type: String

	if not sprite.has_node(type_tag):
		return

	current_type = _ref_ObjectData.get_sprite_type(sprite)

	sprite.get_node(current_type).visible = false
	sprite.get_node(type_tag).visible = true

	current_type = type_tag
	_ref_ObjectData.set_sprite_type(sprite, current_type)