class_name Builder
extends Node2D

var selecting_plot = false
var selection_start = Vector2()
var selection_end = Vector2()

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

var tile_map : TileMap = null

func setup_tile_map(_tile_map):
	if _tile_map:
		tile_map = _tile_map

func _input(event):
	if Input.is_action_just_pressed("set_build_tool_plot"):
		current_build_tool = "plot"
	
	if Input.is_action_just_pressed("set_build_tool_path"):
		current_build_tool = "path"
	
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.pressed:
				selecting_plot = true
				selection_start = tile_map.local_to_map(to_local(event.position))
				selection_end = selection_start
			else:
				selecting_plot = false
				# Here, selection is completed. Do something with it.
				var top_left = Vector2(min(selection_start.x, selection_end.x), min(selection_start.y, selection_end.y))
				var bottom_right = Vector2(max(selection_start.x, selection_end.x), max(selection_start.y, selection_end.y))
				fill_area(top_left, bottom_right)
				print(top_left)
				print(bottom_right)
				queue_redraw()
	elif event is InputEventMouseMotion and selecting_plot:
		selection_end = tile_map.local_to_map(to_local(event.position))
		queue_redraw()

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

func _draw():
	#if is_showing_grid:
		#var screen_size = get_viewport_rect().size
		#var cell_size = Vector2i(16, 16)
		#var grid_color = Color(0.6, 0.6, 0.6, 0.5)  # Light grey, semi-transparent
		#
		## Calculate how many lines to draw based on screen size and cell size
		#var cols = int(screen_size.x / cell_size.x)
		#var rows = int(screen_size.y / cell_size.y)
		#
		## Draw vertical lines
		#for i in range(cols + 1):
			#var x = i * cell_size.x
			#draw_line(Vector2(x, 0), Vector2(x, screen_size.y), grid_color)
		#
		## Draw horizontal lines
		#for j in range(rows + 1):
			#var y = j * cell_size.y
			#draw_line(Vector2(0, y), Vector2(screen_size.x, y), grid_color)
	
	if selecting_plot:
		var start = tile_map.map_to_local(selection_start)
		var end = tile_map.map_to_local(selection_end)
		var top_left = Vector2(min(start.x, end.x), min(start.y, end.y))
		var bottom_right = Vector2(max(start.x, end.x), max(start.y, end.y))
		var rect = Rect2(top_left, bottom_right - top_left)
		draw_rect_corners(rect, 15, 2.5, Color(0.553, 0.647, 0.953, 0.75))

func draw_rect_corners(rect: Rect2, length: float, thickness: float, color: Color):
	# Top left corner
	draw_line(rect.position, rect.position + Vector2(length, 0), color, thickness)
	draw_line(rect.position, rect.position + Vector2(0, length), color, thickness)
	
	# Top right corner
	draw_line(rect.position + Vector2(rect.size.x, 0), rect.position + Vector2(rect.size.x - length, 0), color, thickness)
	draw_line(rect.position + Vector2(rect.size.x, 0), rect.position + Vector2(rect.size.x, length), color, thickness)
	
	# Bottom left corner
	draw_line(rect.position + Vector2(0, rect.size.y), rect.position + Vector2(length, rect.size.y), color, thickness)
	draw_line(rect.position + Vector2(0, rect.size.y), rect.position + Vector2(0, rect.size.y - length), color, thickness)
	
	# Bottom right corner
	draw_line(rect.position + Vector2(rect.size.x, rect.size.y), rect.position + Vector2(rect.size.x - length, rect.size.y), color, thickness)
	draw_line(rect.position + Vector2(rect.size.x, rect.size.y), rect.position + Vector2(rect.size.x, rect.size.y - length), color, thickness)
