class_name FreeMovementAnimations
extends BaseMovementAnimations


@export var audio_footsteps: AudioFootsteps

var _walk_blend: float = 0.0


func move(dir: Vector2, _locked_on: bool, _running: bool) -> void:
	if dir.length() > 0.1:
		_walk_blend = lerp(_walk_blend, 1.0, 0.05)
	else:
		_walk_blend = lerp(_walk_blend, 0.0, 0.1)
	
	anim_tree["parameters/Free Movement/blend_amount"] = _walk_blend
