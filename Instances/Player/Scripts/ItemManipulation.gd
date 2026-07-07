extends Area3D

var ItemInFrontOfPlayer: Node3D 
var ItemSelected: Node3D


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("PickUpItem"):
		if ItemInFrontOfPlayer:
			ItemSelected = ItemInFrontOfPlayer
	
	if ItemSelected:
		var Dir = FindNormal(ItemSelected.global_position, global_position)
		var Length = ItemSelected.global_position.distance_to(global_position)
		ItemSelected.apply_central_force(Dir * clamp(0.4, 0.0, Length))
		
	if ItemSelected and Input.is_action_just_released("PickUpItem"):
		ItemSelected = null

func OnItemEntered(body: Node3D) -> void:
	if body.is_in_group("CanBePickedUp"):
		ItemInFrontOfPlayer = body


func OnItemLeft(body: Node3D) -> void:
	if body.is_in_group("CanBePickedUp"):
		ItemInFrontOfPlayer = null

func FindNormal(Start: Vector3, Target: Vector3) -> Vector3:
	return (Target - Start).normalized()
