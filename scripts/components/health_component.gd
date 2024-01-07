class_name HealthComponent
extends Node3D


signal took_damage
signal zero_health

@export_category("Configuration")
@export var enabled: bool = true

@export_category("Health")
@export var max_health: float = 100.0
@export var health: float = max_health:
	set(value):
		health = clamp(value, 0.0, max_health)

@export_category("Particles")
@export var blood_scene: PackedScene

var deal_max_damage: bool = false



func _ready() -> void:
	health = max_health


func is_alive() -> bool:
	return health > 0


func decrement_health(weapon: Sword) -> void:
	if not enabled:
		return
	
	if blood_scene:
		var blood_particle: GPUParticles3D = blood_scene.instantiate()
		add_child(blood_particle)
		blood_particle.look_at(weapon.global_position)
		blood_particle.rotate_y(PI)
		blood_particle.restart()
	
	if deal_max_damage:
		health = 0
		deal_max_damage = false
	else:
		health -= weapon.get_damage()
	
	took_damage.emit()
	
	if health <= 0:
		zero_health.emit()
