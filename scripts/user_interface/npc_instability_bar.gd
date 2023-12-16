class_name NPCInstabilityBar
extends Node2D


@export var color_gradient: Gradient

var max_instability: float
var instability_bar_visible: bool = false

var _default_instability_sprite_scale_x: float

var _show_instability_bar_timer: Timer
var _show_instability_bar_interval: float = 5.0

@onready var instability_bar: Node2D = $Instability
@onready var glare: Node2D = $Glare


func _ready():
	_default_instability_sprite_scale_x = instability_bar.scale.x
	
	_show_instability_bar_timer = Timer.new()
	_show_instability_bar_timer.wait_time = _show_instability_bar_interval
	_show_instability_bar_timer.autostart = false
	_show_instability_bar_timer.one_shot = true
	_show_instability_bar_timer.timeout.connect(
		func():
			instability_bar_visible = false
	)
	add_child(_show_instability_bar_timer)


func process_instability(instability: float) -> void:
	var instability_percentage = instability / max_instability
	instability_bar.scale.x = lerp(
		0.0, 
		_default_instability_sprite_scale_x,
		instability_percentage
	)
	
	instability_bar.self_modulate = color_gradient.sample(instability_percentage)
	
	if is_equal_approx(instability_percentage, 1.0):
		glare.visible = true
	else:
		glare.visible = false

func instability_increased(_instability: float) -> void:
	instability_bar_visible = true
	_show_instability_bar_timer.start()
