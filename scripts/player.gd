class_name Player
extends AnimatableBody3D

#@onready var skeleton: Skeleton3D = $player_tank/Armature/Skeleton3D
@export var velocity_scaler = 2.71828
@export var angular_acceleration = 3
@export var angular_deceleration = 6.9 * (PI / 180)
@export var bullet_prefab = preload("res://prefabs/bullet.tscn")
@export var explosion_prefab = preload("res://prefabs/explosion.tscn")
@export var turret_rotation_speed = 5

@export var bullet_force = 15

const EPSILON: float = 0.001
var velocity 
var angular
var cumulative_delta 
var last_bullet_fired
var has_been_hit
var tank_skeleton

func _ready():
	velocity = Vector3.ZERO 
	angular = 0.0
	cumulative_delta = 0.0
	last_bullet_fired = 0.0	
	has_been_hit = false
	tank_skeleton = $player_tank/Armature/Skeleton3D
		
func _process(delta):	
	tank_locomotion(delta)	
	turret_rotation(delta)
	
	if Input.is_action_just_pressed("fire"):
		fire()
		
func tank_locomotion(delta):
	# Get analog inputs 
	var tread_speed_left = Input.get_axis("left_axis_back", "left_axis_forward")
	var tread_speed_right = Input.get_axis("right_axis_back", "right_axis_forward")
	#print(tread_speed_left)
	#print(tread_speed_right)
	
	var velocity = 0.0

	if sign(tread_speed_left) != sign(tread_speed_right):
		velocity = tread_speed_left + tread_speed_right
	elif abs(tread_speed_left) > abs(tread_speed_right):
		velocity = tread_speed_left
	else:
		velocity = tread_speed_right
	
	if velocity != 0.0:
		velocity *= transform.basis.z 	* delta * velocity_scaler
		move_and_collide(velocity)
	
	angular = (-tread_speed_left + tread_speed_right) * angular_acceleration * delta
	
	#rotate(Vector3.UP, angular)
	rotate_y(angular)
	
	#self.linear_velocity += velocity * delta * -1
	#transform.origin = transform.origin + velocity * delta 	

func turret_rotation(delta):	
	var turret_transform : Transform3D = tank_skeleton.get_bone_global_pose(1)
	
	var dir : float
	if Input.is_action_pressed("left_shoulder"):
		dir = -1
	if Input.is_action_pressed("right_shoulder"):
		dir = 1
	if Input.is_action_pressed("left_shoulder") and Input.is_action_pressed("right_shoulder"):
		dir = 0
		
	var rotation_amount : Quaternion = Quaternion(Vector3.UP, delta * dir * turret_rotation_speed)
	var quaternion = turret_transform.basis.get_rotation_quaternion() * rotation_amount
	turret_transform.basis = Basis(quaternion)
	tank_skeleton.set_bone_global_pose(1, turret_transform)
	

func fire():	
	var turret_transform : Transform3D = tank_skeleton.get_bone_global_pose(1)
	var bullet_basis = Basis(transform.basis.get_rotation_quaternion() * turret_transform.basis.get_rotation_quaternion())
	
	var new_bullet = bullet_prefab.instantiate()
	new_bullet.global_transform = Transform3D(bullet_basis, transform.origin + turret_transform.origin + bullet_basis.z * 1.3)
	get_tree().current_scene.add_child(new_bullet)
	new_bullet.init(bullet_force)
	last_bullet_fired = cumulative_delta
	
func on_hit():
	if not has_been_hit:
		has_been_hit = true 
		var explosion = explosion_prefab.instantiate() as GPUParticles3D
		get_tree().current_scene.add_child(explosion)
		explosion.emitting = true
		self.queue_free()
		
		
	
