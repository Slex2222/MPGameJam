extends Area3D

var ItemInFrontOfPlayer: Node3D 

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("PickUpItem"):
		if ItemInFrontOfPlayer:
			var dir = FindNormal(ItemInFrontOfPlayer.global_position, global_position)
			ItemInFrontOfPlayer.apply_central_force(dir * 1.0)

func OnItemEntered(body: Node3D) -> void:
	if body is RigidBody3D:
		ItemInFrontOfPlayer = body


func OnItemLeft(body: Node3D) -> void:
	if body is RigidBody3D:
		ItemInFrontOfPlayer = null

func FindNormal(Start: Vector3, Target: Vector3) -> Vector3:
	return (Target - Start).normalized()
