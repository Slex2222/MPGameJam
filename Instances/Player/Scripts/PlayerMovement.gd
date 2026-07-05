extends CharacterBody3D

@export_group("Character Speed")
@export var CrouchSpeed: int = 5
@export var WalkSpeed: int = 10
@export var RunSpeed: int = 15
#@export var JumpSpeed: int = 8

var Speed: int = WalkSpeed

enum PlayerStates {
	Idle,
	Walking,
	Jumping,
	Crouch,
	Sprinting
}

var FlashLightOn: bool = false

var PlayerState: PlayerStates = PlayerStates.Idle

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
	
	if Input.is_action_just_pressed("Crouch"):
		if PlayerState != PlayerStates.Crouch:
			StartCrouch()
		else:
			StopCrouch()
	
	if Input.is_action_just_pressed("Sprint") and PlayerState != PlayerStates.Sprinting:
		StartSprinting()
	
	if Input.is_action_just_released("Sprint") and PlayerState == PlayerStates.Sprinting:
		StopSprinting()
	
	if Input.is_action_just_pressed("TurnOnFlashLight"):
		if FlashLightOn:
			TurnOffFlashLight()
		else:
			TurnOnFlashLight()
	#if Input.is_action_just_pressed("Jump") and is_on_floor():
		#Jump()
	 
	#elif Input.is_action_just_released("Jump") and velocity.y > 0.0:
		#JumpStop()
	
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

func StartCrouch():
	Speed = CrouchSpeed
	
	var tween = create_tween()
	tween.parallel().tween_property($Camera3D, "position:y", 0.25, 0.15)
	
	PlayerState = PlayerStates.Crouch

func StopCrouch():
	Speed = WalkSpeed
	
	var tween = create_tween()
	tween.parallel().tween_property($Camera3D, "position:y", 0.7, 0.15)
	
	PlayerState = PlayerStates.Idle

func StartSprinting():
	PlayerState = PlayerStates.Sprinting
	
	Speed = RunSpeed

func StopSprinting():
	PlayerState = PlayerStates.Idle
	
	Speed = WalkSpeed

func TurnOnFlashLight():
	$Camera3D/Flashlight/SpotLight3D.visible = true
	FlashLightOn = true

func TurnOffFlashLight():
	$Camera3D/Flashlight/SpotLight3D.visible = false
	FlashLightOn = false

#func Jump():
	#velocity.y += JumpSpeed

#func JumpStop():
	#velocity.y = 0.0
