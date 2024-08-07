class_name PlayerParryState
extends PlayerStateMachine


@export var block_state: PlayerBlockState
@export var dizzy_finisher_state: PlayerStateMachine

@onready var dizzy_system: DizzySystem = Globals.dizzy_system

func _ready():
	super._ready()
	
	player.hitbox_component.damage_source_hit.connect(
		func(incoming_damage_source: DamageSource):
			if parent_state.current_state == self:
				player.locomotion_component.knockback(
					incoming_damage_source.damage_attributes.knockback,
					incoming_damage_source.entity.global_position
				)
	)


func enter() -> void:
	player.parry_component.parry()
	player.shield_component.blocking = true
	player.melee_component.interrupt_attack()


func process_player() -> void:
	if Input.is_action_just_pressed("block") and (
		not player.melee_component.attacking or \
		player.melee_component.stop_attacking()
	):
		print("PLEASE PARRY")
		player.parry_component.parry()
		return
	
	if not player.parry_component.in_parry_window:
		if Input.is_action_pressed("block"):
			parent_state.change_state(block_state)
		else:
			parent_state.transition_to_default_state()
		return
	
	player.set_rotation_target_to_lock_on_target()
	
	if dizzy_system.dizzy_victim and dizzy_system.readied_finisher:
		parent_state.change_state(dizzy_finisher_state)


func exit() -> void:
	player.shield_component.blocking = false
