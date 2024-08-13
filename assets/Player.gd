extends CharacterBody3D

# Movement variables
@export var speed := 15.0
@export var gravity := 20.0
@export var jump_force := 10.0
@export var mouse_sensitivity := 0.1  # Adjust this value to change sensitivity

@onready var cam = $CamOrigin

func _ready():
	# Set the mouse mode to captured for full control
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Get the input direction for 3D movement
	var input_dir = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	).normalized()

	# Rotate the input direction based on the camera's orientation
	var camera_basis = cam.global_transform.basis
	input_dir = (
		input_dir.x * camera_basis.x +
		input_dir.z * camera_basis.z
	).normalized()

	# Apply movement
	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed

	# Apply gravity
	velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = jump_force
	
	# Quit action
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	# Move the character
	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		# Register mouse motion
		var mouse_delta = event.relative
		print(event.relative)

		# Handle camera rotation based on mouse motion
		cam.rotation_degrees.x -= mouse_delta.y * mouse_sensitivity
		cam.rotation_degrees.y -= mouse_delta.x * mouse_sensitivity

		# Clamp the vertical rotation to avoid flipping
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -89, 89)

		# Optionally, normalize the horizontal rotation
		cam.rotation_degrees.y = fposmod(cam.rotation_degrees.y, 360)

	if Input.is_action_just_pressed("change_mouse_input"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
