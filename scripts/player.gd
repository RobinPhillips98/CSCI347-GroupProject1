extends CharacterBody2D

signal health_depleted
@onready var animation_tree = $AnimationTree

const MAX_LEVEL: int = 4
const ATTACK_STAMINA_COST = 25

func _ready():
	animation_tree.active = true
	
	if PlayerVariables.max_mana > 0:
		%ManaBar.visible = true
	
	%HealthBar.max_value = PlayerVariables.max_health
	%ManaBar.max_value = PlayerVariables.max_mana
	%StaminaBar.max_value = PlayerVariables.max_stamina
	%XPBar.max_value = PlayerVariables.level_up_value
	%HealthBar.size.x = PlayerVariables.max_health * 2
	%StaminaBar.size.x = PlayerVariables.max_stamina * 3
	%ManaBar.size.x = PlayerVariables.max_mana * 3

func _process(delta):
	%HealthBar.value = PlayerVariables.health
	%ManaBar.value = PlayerVariables.mana
	%StaminaBar.value = PlayerVariables.stamina
	%XPBar.value = PlayerVariables.xp
	
	if PlayerVariables.stamina < PlayerVariables.max_stamina:
		PlayerVariables.stamina += PlayerVariables.stamina_regen_rate * delta

	input()
	
	#Animations
	animation_tree.set("parameters/conditions/idle", velocity == Vector2.ZERO)
	animation_tree.set("parameters/conditions/walk", velocity != Vector2.ZERO)
		
	%XPLabel.text = "XP: " + str(PlayerVariables.xp)
	%HealthPotionNum.text =str(PlayerVariables.health_potions)
	
	if OS.is_debug_build():
		debug_input()

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		animation_tree["parameters/attack/blend_position"] = direction
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/run/blend_position"] = direction
	
	velocity = direction * PlayerVariables.speed
	move_and_slide()
		
func input():
	if Input.is_action_just_pressed("melee_attack") and PlayerVariables.stamina >= ATTACK_STAMINA_COST:
		animation_tree["parameters/conditions/attack"] = true
		$Audio/Attack.play()
		PlayerVariables.stamina -= ATTACK_STAMINA_COST
	else:
		animation_tree["parameters/conditions/attack"] = false
	
	if Input.is_action_just_pressed('hotkey_1') and PlayerVariables.health_potions > 0:
		drink_potion("health_potion")

	if Input.is_action_just_pressed('hotkey_2') and PlayerVariables.mana_potions > 0:
		drink_potion("mana_potion")

func drink_potion(type):
	match type:
		"health_potion":
			PlayerVariables.health += PlayerVariables.max_health * .3
			if PlayerVariables.health > PlayerVariables.max_health:
				PlayerVariables.health = PlayerVariables.max_health
			PlayerVariables.health_potions -= 1
		"mana_potion":
			modify_mana(PlayerVariables.max_mana * .3)
			PlayerVariables.mana_potions -= 1

func gain_potion(type):
	match type:
		"health_potion":
			PlayerVariables.health_potions += 1
		"mana_potion":
			PlayerVariables.mana_potions += 1
	$Audio/Pickup.play()
	
func take_damage(damage):
	PlayerVariables.health -= damage
	$Audio/HitReceived.play()
	$Audio/Damage.play()
	
	if PlayerVariables.health <= 0.0:
		$Audio/GameOver.play()
		Global.game_over()
		
func get_health():
	return PlayerVariables.health

func be_healed(value):
	PlayerVariables.health += value
	if PlayerVariables.health > PlayerVariables.max_health:
		PlayerVariables.health = PlayerVariables.max_health

func modify_mana(value):
	PlayerVariables.mana += value
	if PlayerVariables.mana < 0:
		PlayerVariables.mana = 0
	elif PlayerVariables.mana > PlayerVariables.max_mana:
		PlayerVariables.mana = PlayerVariables.max_mana

func get_mana():
	return PlayerVariables.mana
	
func get_stamina():
	return PlayerVariables.stamina
	
func modify_stamina(value):
	PlayerVariables.stamina += value
	if PlayerVariables.stamina < 0:
		PlayerVariables.stamina = 0
	elif PlayerVariables.stamina > PlayerVariables.max_stamina:
		PlayerVariables.stamina = PlayerVariables.max_stamina

func gain_xp(value):
	PlayerVariables.xp += value
	if PlayerVariables.xp < 0:
		PlayerVariables.xp = 0
	if PlayerVariables.xp >= PlayerVariables.level_up_value and PlayerVariables.level <= MAX_LEVEL:
		level_up()

func gain_money(value):
	PlayerVariables.money += value

func get_money():
	return PlayerVariables.money

func level_up():
	if PlayerVariables.level >= MAX_LEVEL:
		return
	
	gain_xp(-PlayerVariables.level_up_value)
	PlayerVariables.level += 1
	PlayerVariables.level_up_value += 500
	%XPBar.max_value = PlayerVariables.level_up_value
	
	PlayerVariables.max_health += 100
	%HealthBar.max_value = PlayerVariables.max_health
	PlayerVariables.health += 100
	%HealthBar.size.x = PlayerVariables.max_health * 2
	
	PlayerVariables.max_mana += 50.0
	%ManaBar.max_value = PlayerVariables.max_mana
	PlayerVariables.mana +=50
	%ManaBar.size.x = PlayerVariables.max_mana * 3
	if %ManaBar.visible == false:
		%ManaBar.visible = true
	
	PlayerVariables.max_stamina += 25
	%StaminaBar.max_value = PlayerVariables.max_stamina
	PlayerVariables.stamina += 25
	%StaminaBar.size.x = PlayerVariables.max_stamina * 3
	
	
	$Audio/LevelUp.play()

func _on_sword_body_entered(body):
	if body.has_method("take_damage"):
			body.take_damage(10)
			$Audio/Hit.play()

func debug_input():
	if Input.is_action_just_pressed("debug_level_up"):
		level_up()
		
func next_level():
	Global.next_level()
