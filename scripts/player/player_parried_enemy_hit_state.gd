class_name PlayerParriedEnemyHitState
extends PlayerStateMachine


@export var block_state: PlayerBlockState
@export var parry_state: PlayerParryState

var _timer: Timer
var _timer_length: float = 0.5


func _ready():
	super._ready()
	
	player.parry_component.parried_incoming_hit.connect(
		func():
			parent_state.change_state(self)
	)
	
	_timer = Timer.new()
	_timer.wait_time = _timer_length
	_timer.autostart = false
	_timer.one_shot = true
	_timer.timeout.connect(
		func():
			parent_state.transition_to_default_state()
	)
	add_child(_timer)


func enter():
	player.movement_component.speed = 3
	player.block_component.blocking = true
	_timer.start()


func process_player():
	if Input.is_action_just_pressed("block"):
		parent_state.change_state(parry_state)
		return
	
	if Input.is_action_pressed("block"):
		parent_state.change_state(block_state)
		return


func exit():
	player.block_component.blocking = false
	_timer.stop()
