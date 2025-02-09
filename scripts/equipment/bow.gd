extends Area2D

@onready var player = get_node("/root/Game/Player")
const STAMINA_COST = 50

func _physics_process(delta):
	input()
	
	#var enemies_in_range = get_overlapping_bodies()
	#
	#if enemies_in_range.size() > 0:
		#var target_enemy = enemies_in_range[0]
		#look_at(target_enemy.global_position)
		
func input():
	look_at(get_global_mouse_position())
		
	
	if Input.is_action_just_pressed("ranged_attack") and player.get_stamina() >= STAMINA_COST:
		shoot()

func shoot():
	player.modify_stamina(-STAMINA_COST)
	const ARROW = preload("res://scenes/equipment/arrow.tscn")
	var new_arrow = ARROW.instantiate()
	new_arrow.global_position = %ShootingPoint.global_position
	new_arrow.global_rotation = %ShootingPoint.global_rotation
	%ShootingPoint.add_child(new_arrow)
