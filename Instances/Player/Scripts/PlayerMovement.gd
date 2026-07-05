extends CharacterBody3D

@export var Speed: int = 10
@export var JumpSpeed: int = 8

enum PlayerStates {
	Idle,
	Walking,
	Jumping,
}

var PlayerState: PlayerStates = PlayerStates.Idle

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ShowUI()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.25
		$Camera3D.rotation_degrees.x -= event.relative.y * 0.25
		$Camera3D.rotation_degrees.x = clamp(
			$Camera3D.rotation_degrees.x, -80.0, 80.0
		)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta 
	
	Walk()
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		Jump()

	move_and_slide()

func Walk():
	var InputDirection2D = Input.get_vector(
		"Left", "Right", "Forward", "Backwards"
	)
	var InputDirection3D = Vector3(
		InputDirection2D.x, 0.0, InputDirection2D.y
	)
	
	InputDirection3D = transform.basis * InputDirection3D
	InputDirection3D = InputDirection3D.normalized()
	
	velocity.x = InputDirection3D.x * Speed
	velocity.z = InputDirection3D.z * Speed
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		Jump()
	 
	elif Input.is_action_just_released("Jump") and velocity.y > 0.0:
		JumpStop()

func Jump():
	velocity.y += JumpSpeed

func JumpStop():
	velocity.y = 0.0

func ShowUI():
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = $SubViewport.get_texture()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	$"Display UI".material_override = mat
