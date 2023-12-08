class_name NoticeComponentSuspiciousState
extends NoticeComponentState


@export var idle_state: NoticeComponentIdleState
@export var getting_aggro_state: NoticeComponentGettingAggroState
@export var aggro_state: NoticeComponentAggroState

var _expand_x: float
var _expand_scale: float

var _suspicion_timer: Timer
var _can_start_suspicion_timer: bool = true
var _suspicion_interval: float = 20.0
var _check_to_leave_suspicion: bool = false

var _before_getting_aggro_timer: Timer
var _before_getting_aggro_pause: float = 2.0
var _check_to_get_aggro: bool = false


func _ready():
	_suspicion_timer = Timer.new()
	_suspicion_timer.wait_time = _suspicion_interval
	_suspicion_timer.one_shot = true
	_suspicion_timer.autostart = false
	_suspicion_timer.timeout.connect(
		func(): 
			_check_to_leave_suspicion = true
	)
	add_child(_suspicion_timer)
	
	
	_before_getting_aggro_timer = Timer.new()
	_before_getting_aggro_timer.wait_time = _before_getting_aggro_pause
	_before_getting_aggro_timer.one_shot = true
	_before_getting_aggro_timer.autostart = false
	_before_getting_aggro_timer.timeout.connect(
		func():
			_check_to_get_aggro = true
	)
	add_child(_before_getting_aggro_timer)


func enter() -> void:
	_expand_x = 0
	
	_check_to_leave_suspicion = false
	_can_start_suspicion_timer = true
	
	notice_component.position_to_check = notice_component.player.global_position
	
	if notice_component.distance_to_player > 0.9 * notice_component.outer_distance:
		_before_getting_aggro_timer.start()
	else:
		_check_to_get_aggro = true


func physics_process(delta) -> void:
#	if notice_component.debug: prints(_before_getting_aggro_timer.time_left)
	
	notice_component.notice_triangle_sprite.visible = true
	
	_expand_scale = notice_component.expand_curve.sample(_expand_x)
	
	notice_component.notice_triangle_sprite.scale = \
		notice_component.original_triangle_scale * \
		Vector2(_expand_scale, _expand_scale)
		
	_expand_x += 3.0 * delta
	
	if _expand_x >= 0.5:
		# make the entire triangle yellow
		notice_component.notice_triangle_sprite.self_modulate = \
			lerp(
				notice_component
					.notice_triangle_sprite
					.self_modulate,
				notice_component.suspicion_color,
				0.2
			)
	
	if notice_component.inside_inner_threshold():
		notice_component.transition_to_aggro()
		_before_getting_aggro_timer.stop()
		return
	elif _check_to_leave_suspicion:
		notice_component.change_state(idle_state)
	elif _check_to_get_aggro:
		notice_component.change_state(getting_aggro_state)
	
	if not notice_component.in_camera_frustum():
		notice_component.notice_triangle_sprite.visible = false

func exit() -> void:
	pass


func interrupt() -> void:
	_suspicion_timer.stop()
