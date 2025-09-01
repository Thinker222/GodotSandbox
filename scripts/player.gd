extends MeshInstance3D

@export var acceleration = 1
@export var deceleration = 3
@export var angular_acceleration = 0.6* (PI / 180)
@export var angular_deceleration = 0.9 * (PI / 180)

const EPSILON: float = 0.001
var velocity 
var angular_velocity

func _ready():
	velocity = Vector3.ZERO 
	angular_velocity = 0.0
	
func _process(delta):
	
	var is_accelerating = false 
	var is_angular_accelerating = false
	
	if Input.is_action_pressed("forward"):
		velocity += acceleration * transform.basis.z * delta
		is_accelerating = true
	if Input.is_action_pressed("left"):
		angular_velocity += angular_acceleration * delta
		is_angular_accelerating = true
	if Input.is_action_pressed("right"):
		angular_velocity -= angular_acceleration * delta
		is_angular_accelerating = true
	if Input.is_action_pressed("back"): 
		velocity -= acceleration * transform.basis.z * delta
	if Input.is_action_just_pressed("fire"):
		pass
	
	rotate(Vector3.UP, angular_velocity)
	transform.origin = transform.origin + velocity * delta 
	
	
	var norm = velocity.length()
	if norm != 0 and !is_accelerating:
		velocity /= norm 
		norm += -deceleration * delta
		velocity *= norm 
	
	if !is_angular_accelerating:
		if angular_velocity < 0: 
			angular_velocity += delta * angular_deceleration
		else: 
			angular_velocity -= delta * angular_deceleration
		
	#angular_velocity =  lerp(angular_velocity, 0.0, angular_velocity * .1)
	#print(angular_velocity)
	
	
	
