extends MeshInstance3D

@export var acceleration = 100
@export var deceleration = 30
@export var angular_acceleration = 3
@export var angular_deceleration = 6.9 * (PI / 180)

const EPSILON: float = 0.001
var velocity 
var angular_velocity

func _ready():
	velocity = Vector3.ZERO 
	angular_velocity = 0.0
	
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
	
	
	#var is_accelerating = false 
	#var is_angular_accelerating = false
	#
	#if Input.is_action_pressed("forward"):
		#velocity += acceleration * transform.basis.z * delta
		#is_accelerating = true
	#if Input.is_action_pressed("left"):
		#angular_velocity = angular_acceleration * delta
		#is_angular_accelerating = true
	#if Input.is_action_pressed("right"):
		#angular_velocity = -angular_acceleration * delta
		#is_angular_accelerating = true
	#if Input.is_action_pressed("back"): 
		#velocity -= acceleration * transform.basis.z * delta
		#is_accelerating = true
	#if Input.is_action_just_pressed("fire"):
		#pass
	#
	#rotate(Vector3.UP, angular_velocity)
	#transform.origin = transform.origin + velocity * delta 
	#
	#var norm = velocity.length()
	#if norm != 0 and !is_accelerating:
		#velocity /= norm 
		#norm += -deceleration * delta
		#velocity *= norm 
	#
	#if !is_angular_accelerating:
		#if angular_velocity < 0: 
			#angular_velocity += delta * angular_deceleration
		#else: 
			#angular_velocity -= delta * angular_deceleration
		
	#angular_velocity =  lerp(angular_velocity, 0.0, angular_velocity * .1)
	#print(angular_velocity)
	
	
	
