extends Node

var player_scene = preload("res://scenes/player.tscn")
var player_camera_scene = preload("res://scenes/player_camera.tscn")

var areas : Dictionary = {
	"farm_area" : preload("res://scenes/farm_area.tscn")
}

var player : Player = null
var player_camera : PlayerCamera = null
var current_area : Area = null

func load_area(_area_name):
	if current_area:
		current_area.queue_free()
	
	var new_area_scene = areas[_area_name]
	var new_area = new_area_scene.instantiate()
	get_node("/root/Game").call_deferred("add_child", new_area)
	
	current_area = new_area
	
	call_deferred("setup_player")

func setup_player():
	if not player or player.is_queued_for_deletion():
		player = player_scene.instantiate()
	player.setup_tile_map(current_area.tile_map)
	get_node("/root/Game").add_child(player)
	player_camera = player_camera_scene.instantiate()
	current_area.add_child(player_camera)
