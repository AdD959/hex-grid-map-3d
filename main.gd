extends Node3D

@onready var camera_isometric: Camera3D = $CameraRig/CameraIsometric
@onready var camera_top_down: Camera3D = $CameraRig/CameraTopDown
@onready var map_base: Node3D = $MapBase
@onready var ui: CanvasLayer = $UI

func _ready() -> void:
	Globals.camera_isometric = camera_isometric
	Globals.camera_top_down = camera_top_down
	Globals.cameras = [Globals.camera_isometric, Globals.camera_top_down]
	Globals.selected_camera = Globals.camera_isometric
	Globals.selected_camera.current = true
	map_base.begin()
