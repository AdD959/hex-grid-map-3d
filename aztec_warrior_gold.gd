extends Node3D

var _outer_tile_position: Vector2i
var _inner_tile_position: Vector2i

var move_duration := 0.2  # seconds

# Active tween reference
var tween: Tween = null
var move_queue: Array[Vector3] = []

var outer_tile_position: Vector2i:
	set(value):
		if value != _outer_tile_position:
			_outer_tile_position = value
	get:
		return _outer_tile_position

var inner_tile_position: Vector2i:
	set(value):
		if value != _inner_tile_position:
			_inner_tile_position = value
			_queue_move()
	get:
		return _inner_tile_position

func _queue_move():
	# Resolve final target position
	if not Globals.tile_data_map.has(_outer_tile_position):
		push_error("Invalid outer tile position: %s" % _outer_tile_position)
		return
	
	var outer_tile = Globals.tile_data_map[_outer_tile_position]
	var inner_map = outer_tile.inner_tiles_data_map
	
	if not inner_map.has(_inner_tile_position):
		push_error("Invalid inner tile position: %s" % _inner_tile_position)
		return
	
	var target_position: Vector3 = outer_tile.position + inner_map[_inner_tile_position]["position"]
	
	# Add to queue
	move_queue.append(target_position)
	_process_next_move()

func _process_next_move():
	if tween != null and tween.is_running():
		return
	if move_queue.is_empty():
		return
	
	var next_target = move_queue.pop_front()
	var ease = true if move_queue.is_empty() or move_queue.size() == 0 else false

	tween = create_tween()
	var tween_step = tween.tween_property(self, "position", next_target, move_duration)
	
	if ease:
		tween_step.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	else:
		tween_step.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(_process_next_move)
