class_name Bullet 
extends RigidBody3D


@export var bullet_timeout = 10.0 
@export var bullet_force = 5
var bullet_direction 

var cumulative_time 

func _ready():
	gravity_scale = 0.0
	pass

func init():
	cumulative_time = 0
	bullet_direction  = global_transform.basis.z
	apply_impulse(bullet_direction * bullet_force, Vector3.ZERO)
	print("Creating Bullet and applying impulse")
	print(transform.origin)
	

func _process(delta):
	cumulative_time += delta  
	if cumulative_time >= bullet_timeout:
		print("Destroying bullet")
		queue_free()
	
