extends Camera2D
class_name PlayerCamera
# Base movement speed for the camera
@export var base_move_speed: float = 200.0
# Zoom speed and limits
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.2
@export var max_zoom: float = 3.0
# Smoothing factor for movement
@export var movement_smooth_factor: float = 5.0
# Speed multiplier when holding the shift key
@export var shift_speed_multiplier: float = 2.0
# Current zoom target
var target_zoom: Vector2
# Velocity for smooth movement
var velocity: Vector2 = Vector2.ZERO

func _ready():
	position = Vector2(get_viewport().get_visible_rect().size.x / 2, get_viewport().get_visible_rect().size.y / 2)
	target_zoom = zoom

func _process(delta):
	var movement = Vector2.ZERO

	# WASD movement
	if Input.is_action_pressed("camera_move_up"):
		movement.y -= 1
	if Input.is_action_pressed("camera_move_down"):
		movement.y += 1
	if Input.is_action_pressed("camera_move_left"):
		movement.x -= 1
	if Input.is_action_pressed("camera_move_right"):
		movement.x += 1

	# Normalize movement vector and apply speed
	if movement != Vector2.ZERO:
		movement = movement.normalized()
	
	# Calculate actual movement speed based on zoom level
	var zoom_factor = (zoom.x + zoom.y) / 2.0
	var move_speed = base_move_speed / zoom_factor
	
	# Increase speed when holding LEFT SHIFT
	if Input.is_action_pressed("camera_speed_boost"):
		move_speed *= shift_speed_multiplier
	
	# Interpolate velocity for smooth movement
	velocity = lerp(velocity, movement * move_speed, movement_smooth_factor * delta)
	position += velocity * delta
	
	handle_zoom(delta)

func _input(event):
	# Handle zoom input
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			target_zoom = (target_zoom + Vector2(zoom_speed, zoom_speed)).clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			target_zoom = (target_zoom - Vector2(zoom_speed, zoom_speed)).clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func handle_zoom(delta):
	# Smoothly interpolate the zoom
	zoom = lerp(zoom, target_zoom, 5 * delta)
