extends CharacterBody3D

@export_group("Character Speed")
@export var CrouchSpeed: int = 2
@export var WalkSpeed: int = 4
@export var RunSpeed: int = 8
#@export var JumpSpeed: int = 8

var Speed: int = WalkSpeed

@onready var Animations: AnimationPlayer = $PlayerMesh/PlayerAnimations/AnimationPlayer

#var PlayerNormalStateMat: Material = preload("res://Instances/Player/Materials/PlayerNormal.tres")
#var PlayerMannequinStateMat: Material = preload("res://Instances/Player/Materials/PlayerMannequin.tres")

#@onready var PlayerMesh: MeshInstance3D = $PlayerMesh

enum PlayerStates {
	Idle,
	Walking,
	Jumping,
	Crouch,
	Sprinting
}

var PlayerState: PlayerStates = PlayerStates.Idle

var IsMannequin: bool = false
var FlashLightOn: bool = false

var LastActionTimer: float = 0.0

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
	
	#CounterActionTimer(delta)

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
	
	ModifyAnimationSpeed(InputDirection2D)
	#if InputDirection3D:
		#ResetActionTimer()

func StartCrouch():
	Speed = CrouchSpeed
	
	
	Animations.play("croutch", 0.2)
	#var tween = create_tween()
	#for child in get_children():
		#if child.is_in_group("CanScale"):
			#tween.parallel().tween_property(child, "scale:y", 0.6, 0.15)
	
	PlayerState = PlayerStates.Crouch
	
	#ResetActionTimer()

func StopCrouch():
	Speed = WalkSpeed
	
	Animations.play("walk", 0.2)
	#var tween = create_tween()
	#for child in get_children():
		#if child.is_in_group("CanScale"):
			#tween.parallel().tween_property(child, "scale:y", 1.0, 0.15)
	
	PlayerState = PlayerStates.Idle
	
	#ResetActionTimer()

func StartSprinting():
	PlayerState = PlayerStates.Sprinting
	
	Animations.play("light_run", 0.2)
	
	Speed = RunSpeed

func StopSprinting():
	PlayerState = PlayerStates.Idle
	
	Animations.play("walk", 0.2)
	
	Speed = WalkSpeed

func TurnOnFlashLight():
	$Flashlight/SpotLight3D.visible = true
	FlashLightOn = true
	#ResetActionTimer()

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


func ModifyAnimationSpeed(InputDirection2D):
	if InputDirection2D.y > 0:
		Animations.speed_scale = -1.0
	elif InputDirection2D.y < 0:
		Animations.speed_scale = 1.0
	elif InputDirection2D.x != 0:
		Animations.speed_scale = 1.0
	else:
		Animations.speed_scale = 0.0

#func TurnOnMannequinMode():
	#PlayerMesh.set_surface_override_material(0, PlayerMannequinStateMat)
	#IsMannequin = true
#
#func TurnOffMannequinMode():
	#PlayerMesh.set_surface_override_material(0, PlayerNormalStateMat)
	#IsMannequin = false

#func CounterActionTimer(delta):
	#LastActionTimer += delta
	#
	#if LastActionTimer > 1.0:
		#TurnOnMannequinMode()
#
#func ResetActionTimer():
	#LastActionTimer = 0.0
	#
	#TurnOffMannequinMode()
#func Jump():
	#velocity.y += JumpSpeed

#func JumpStop():
	#velocity.y = 0.0
