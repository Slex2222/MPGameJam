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
	
	ApplyVelocityToRigidBodies()

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
	for child in get_children():
		if child.is_in_group("CanScale"):
			tween.parallel().tween_property(child, "scale:y", 0.6, 0.15)
	
	PlayerState = PlayerStates.Crouch

func StopCrouch():
	Speed = WalkSpeed
	
	var tween = create_tween()
	for child in get_children():
		if child.is_in_group("CanScale"):
			tween.parallel().tween_property(child, "scale:y", 1.0, 0.15)
	
	PlayerState = PlayerStates.Idle

func StartSprinting():
	PlayerState = PlayerStates.Sprinting
	
	Speed = RunSpeed

func StopSprinting():
	PlayerState = PlayerStates.Idle
	
	Speed = WalkSpeed

func TurnOnFlashLight():
	$Flashlight/SpotLight3D.visible = true
	FlashLightOn = true

func TurnOffFlashLight():
	$Flashlight/SpotLight3D.visible = false
	FlashLightOn = false


func ApplyVelocityToRigidBodies():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is RigidBody3D:
			# Push the object in the direction the player is moving
			var push_direction = -collision.get_normal()
			collision.get_collider().apply_central_force(push_direction * 1.0)
#func Jump():
	#velocity.y += JumpSpeed

#func JumpStop():
	#velocity.y = 0.0
