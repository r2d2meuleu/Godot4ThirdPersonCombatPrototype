class_name Enemy
extends CharacterBody3D

signal death(enemy)

@export var target: Node3D
@export var debug: bool = false
@export var friction: float = 0.05

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _blackboard: Blackboard = $Blackboard
@onready var _character: PlayerAnimations = $Model
@onready var _rotation_component: RotationComponent = $EnemyRotationComponent
@onready var _movement_component: MovementComponent = $MovementComponent
@onready var _backstab_component: BackstabComponent = $BackstabComponent
@onready var _agent: NavigationAgent3D = $NavigationAgent3D

var _default_move_speed: float


func _ready() -> void:
	target = Globals.player
	_rotation_component.target = target
	_blackboard.set_value("debug", debug)
	_default_move_speed = _movement_component.speed
	_blackboard.set_value("move_speed", _default_move_speed)
	
	_rotation_component.debug = debug
	_movement_component.debug = debug
	$BackstabComponent.debug = debug
	
	_blackboard.set_value("notice_player", false)
	_blackboard.set_value("dead", false)


func _physics_process(_delta: float) -> void:
	_agent.target_position = target.global_position

	var target_dist: float = global_position.distance_to(target.global_position)
	var target_dir: Vector3 = global_position.direction_to(target.global_position)
	var target_dir_angle: float = target_dir.angle_to(Vector3.FORWARD.rotated(Vector3.UP, global_rotation.y))

	_blackboard.set_value("target", target)
	_blackboard.set_value("target_dist", target_dist)
	_blackboard.set_value("target_dir", target_dir)
	_blackboard.set_value("target_dir_angle", target_dir_angle)

	if debug:
		pass
#		print(_blackboard.get_value("look_at_target"))
#		print(_rotation_component.look_at_target)
#		print(_blackboard.get_value("input_direction", Vector3.ZERO))
#		print(_rotation_component.move_direction, " ", _movement_component.desired_velocity)

	_rotation_component.look_at_target = _blackboard.get_value("look_at_target", false)
	_movement_component.speed = _blackboard.get_value("move_speed", _default_move_speed)

	var _input_direction: Vector3 = _blackboard.get_value("input_direction", Vector3.ZERO)
	var _locked_on: bool = _blackboard.get_value("locked_on", false)
	_character.anim_tree["parameters/Lock On Walk/4/TimeScale/scale"] = 0.5
	_character.anim_tree["parameters/Lock On Walk/5/TimeScale/scale"] = 0.5	
	_character.movement_animations.move(_input_direction, _locked_on, false)


func _on_entity_hitbox_weapon_hit(weapon: Sword) -> void:
	var opponent_position: Vector3 = weapon.get_entity().global_position
	var direction: Vector3 = global_position.direction_to(opponent_position)
	_movement_component.set_secondary_movement(weapon.get_knockback(), 5, 5, -direction)
	_blackboard.set_value("notice_player", true)


func _on_health_component_zero_health() -> void:
	print('hi')
	death.emit(self)
	
	_blackboard.set_value("dead", true)
	_blackboard.set_value("interrupt_timers", true)
	
	collision_layer = 0
	collision_mask = 1
	
	if Globals.backstab_system.backstab_victim == _backstab_component:
		_character.anim_tree["parameters/Death/transition_request"] = "backstab"
	else:
		_character.anim_tree["parameters/Death/transition_request"] = "dead"
