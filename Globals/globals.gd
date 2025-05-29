extends Node

var camera_isometric: Camera3D
var camera_top_down: Camera3D

var cameras: Array = [Camera3D]
var selected_camera: Camera3D = null 

const GRID_WIDTH:= 15
const GRID_HEIGHT:= 15
