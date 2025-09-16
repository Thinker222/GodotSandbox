extends MeshInstance3D

#@onready var skeleton: Skeleton3D = $player_tank/Armature/Skeleton3D
@export var acceleration = 100
@export var deceleration = 30
@export var angular_acceleration = 3
@export var angular_deceleration = 6.9 * (PI / 180)
@export var bullet_prefab = preload("res://prefabs/bullet.tscn")

const EPSILON: float = 0.001
var velocity 
var angular_velocity
var cumulative_delta 
var last_bullet_fired

func _ready():
	velocity = Vector3.ZERO 
	angular_velocity = 0.0
	cumulative_delta = 0.0
	last_bullet_fired = 0.0	
		
func _process(delta):
	
	# Get analog inputs 
	var tread_speed_left = Input.get_axis("left_axis_back", "left_axis_forward")
	var tread_speed_right = Input.get_axis("right_axis_back", "right_axis_forward")
	
	var velocity = 0.0

	if sign(tread_speed_left) != sign(tread_speed_right):
		velocity = tread_speed_left + tread_speed_right
	elif abs(tread_speed_left) > abs(tread_speed_right):
		velocity = tread_speed_left
	else:
		velocity = tread_speed_right
	
	velocity *= transform.basis.z 	
	
	angular_velocity = (-tread_speed_left + tread_speed_right) * angular_acceleration * delta
	
	rotate(Vector3.UP, angular_velocity)
	transform.origin = transform.origin + velocity * delta 
	
	var skeleton = $player_tank/Armature/Skeleton3D
	
	var turret_transform : Transform3D = skeleton.get_bone_global_pose(1)
	cumulative_delta += delta
	var rotation_amount : Quaternion = Quaternion(Vector3.UP, delta)
	var quaternion = turret_transform.basis.get_rotation_quaternion() * rotation_amount
	turret_transform.basis = Basis(quaternion)
	skeleton.set_bone_global_pose(1, turret_transform)
	
	
	if cumulative_delta - last_bullet_fired > 1.0:
		var new_bullet = bullet_prefab.instantiate()
		new_bullet.global_transform = Transform3D(turret_transform.basis, turret_transform.origin + turret_transform.basis.z * 1.3)
		get_tree().current_scene.add_child(new_bullet)
		new_bullet.init()
		last_bullet_fired = cumulative_delta
		print("trigger")
	
