extends Node3D

var _outer_tile_position: Vector2i
var _inner_tile_position: Vector2i

var outer_tile_position: Vector2i:
	set(value):
		if value != _outer_tile_position:
			_outer_tile_position = value
			_move()
	get:
		return _outer_tile_position

var inner_tile_position: Vector2i:
	set(value):
		if value != _inner_tile_position:
			_inner_tile_position = value
			_move()
	get:
		return _inner_tile_position

func _move():
	position = Globals.tile_data_map[_outer_tile_position].position
	position += Globals.tile_data_map[_outer_tile_position].inner_tiles_data_map[inner_tile_position]
	print(position)
