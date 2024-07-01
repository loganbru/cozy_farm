class_name Player
extends Node2D

var build_tools = {
	"plot" : {
		"center_tile" : Vector2i(5, 9),
		"terrain_index" : 1
	},
	"path" : {
		"center_tile" : Vector2i(5, 6),
		"terrain_index" : 2
	}
}

var current_build_tool = "path"

# Reference to the TileMap node
var tile_map: TileMap
# Variables to track the selection state
var selecting: bool = false
var selection_start: Vector2
var selection_end: Vector2

func setup_tile_map(_tile_map):
	if _tile_map:
		tile_map = _tile_map

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start selection
				selecting = true
				selection_start = tile_map.local_to_map(get_global_mouse_position())
				selection_end = selection_start # Initialize end point
			else:
				# End selection
				selecting = false
				selection_end = tile_map.local_to_map(get_global_mouse_position())
				select_tiles_in_area(selection_start, selection_end)
				var top_left = Vector2(min(selection_start.x, selection_end.x), min(selection_start.y, selection_end.y))
				var bottom_right = Vector2(max(selection_start.x, selection_end.x), max(selection_start.y, selection_end.y))
				fill_area(top_left, bottom_right)
				queue_redraw()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Single tile selection
			var tile_pos = tile_map.local_to_map(get_global_mouse_position())
			select_single_tile(tile_pos)
			queue_redraw()

func _process(delta):
	if selecting:
		# Update selection end point while selecting
		selection_end = tile_map.local_to_map(get_global_mouse_position())
		queue_redraw()

func select_single_tile(tile_pos: Vector2):
	# Handle single tile selection
	print("Select tile: " + str(tile_pos))

func select_tiles_in_area(start: Vector2, end: Vector2):
	print("Select area: " + str(start) + " to " + str(end))

func _draw():
	if selecting or (not selecting and selection_start != selection_end):
		# Convert selection start and end to world coordinates
		var start_pos = tile_map.map_to_local(selection_start)
		var end_pos = tile_map.map_to_local(selection_end)

		# Determine the rectangle corners
		var rect_position = start_pos
		var rect_size = end_pos - start_pos

		# Adjust for negative sizes if dragging left/up
		if rect_size.x < 0:
			rect_position.x += rect_size.x
			rect_size.x = abs(rect_size.x)
		if rect_size.y < 0:
			rect_position.y += rect_size.y
			rect_size.y = abs(rect_size.y)

		# Draw the selection rectangle
		draw_rect(Rect2(rect_position, rect_size), Color(1, 1, 1, 0.5), false)

func fill_area(start, end):
	var area_width = end.x - start.x
	var area_height = end.y - start.y
	var area_cells = []
	if area_width >= 2 and area_height >= 2:
		# update terrain cells
		for x in range(start.x, end.x + 1):
			for y in range(start.y, end.y + 1):
				var pos = Vector2i(x, y)
				area_cells.push_back(pos)
		
		tile_map.set_cells_terrain_connect(0, area_cells, 0, build_tools[current_build_tool].terrain_index)
