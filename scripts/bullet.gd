class_name Bullet 
extends RigidBody3D


@export var bullet_timeout = 10.0 
@export var attenuation = 0.9
var bullet_force 
var bullet_direction 
var velocity : Vector3
var cumulative_time 
var hit_count = 0


func _ready():
	gravity_scale = 0.0
	
	contact_monitor = true
	max_contacts_reported = 10
	connect("collision_info", _on_collision_info)
	pass

func init(_bullet_force):
	bullet_force = _bullet_force
	cumulative_time = 0
	bullet_direction  = global_transform.basis.z
	velocity = bullet_direction * bullet_force;
	apply_impulse(velocity, Vector3.ZERO)
	#print("Creating Bullet and applying impulse")
	#print(transform.origin)
	

func _process(delta):
	cumulative_time += delta  
	if cumulative_time >= bullet_timeout:
		#print("Destroying bullet")
		queue_free()
		
signal collision_info(body, position, normal)

func _integrate_forces(state):
	var contact_count = state.get_contact_count()
	for i in range(contact_count):
		var collider = state.get_contact_collider_object(i)
		if collider:
			var pos = state.get_contact_local_position(i)
			var world_pos = to_global(pos)
			var normal = state.get_contact_local_normal(i)
			emit_signal("collision_info", collider, world_pos, normal)

func _on_collision_info(collider: Node, position: Vector3, normal: Vector3):
	hit_count += 1
	var v = velocity.normalized()
	var new_angle = v.dot(normal)
	var newer_angle = acos(new_angle)
	
	var cross = v.cross(normal).normalized()	
	var newest_angle = v.rotated(cross, newer_angle)
		
	var attenuated_velocity = newest_angle * (bullet_force * attenuation / hit_count)	
	apply_impulse(attenuated_velocity, Vector3.ZERO)
	velocity = attenuated_velocity;
	if collider is Player:
		var player = collider as Player 
		player.on_hit()
		
