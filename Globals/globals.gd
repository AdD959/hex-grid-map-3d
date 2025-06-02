extends Node

var camera_isometric: Camera3D
var camera_top_down: Camera3D

var cameras: Array = [Camera3D]
var selected_camera: Camera3D = null 

const GRID_WIDTH:= 5
const GRID_HEIGHT:= 5

var tile_data_map:= {}

var selected_unit = null

var grass_tile: MultiMeshInstance3D
var dark_grass_tile: MultiMeshInstance3D
var tree_1_multimesh: MultiMeshInstance3D

var multimesh_instance_indices := {
	"grass": 0,
	"dark_grass": 0,
	"water": 0
}

var tile_instance_refences: Dictionary = {}
