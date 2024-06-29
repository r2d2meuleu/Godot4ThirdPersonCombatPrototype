class_name ParryInteractionHandler
extends InteractionHandler


@export var blackboard: Blackboard
@export var parry_component: ParryComponent
@export var parry_animations: ParryAnimations
@export var block_component: BlockComponent
@export var parry_sfx: AudioStreamPlayer3D
@export var instability_component: InstabilityComponent


func handle_interaction(incoming_weapon: Weapon) -> bool:
	interaction.emit()
	
	parry_component.in_parry_window = true
	parry_component.play_parry_particles()
	parry_animations.parry()
	block_component.anim.play("parried")
	instability_component.process_parry()
	incoming_weapon.parry_weapon()
	if parry_sfx: parry_sfx.play()
	
	return true