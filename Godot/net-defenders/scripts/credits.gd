extends Control

@onready var scroll_container = $ScrollContainer
@onready var credits_vbox = $ScrollContainer/Credits
@onready var back_button = $BackButton
@onready var background = $ColorRect


var credit_lines = [
	"Game Design: Group 2",
	"Programming: Espinosa",
	"Art & Assets: Free Asset Sources",
	"Music: Free Music Sources",
	"Research Team:",
	"Espinosa Cyruss Andrei",
	"Rebutta Rachelle",
	"Duritan Ara",
	"Navarro James Carlos",
	"Kishan Erolin",
	"Caduyac Donde",
	"Manabat Clifford",
	"Mendoza Aaron",
	"Macalalad Zedrick Gabriel",
	"Lim Jon Davis",
	"Special Thanks: Teachers & Classmates"
]

var scroll_speed: float = 50.0
var fade_duration: float = 0.5
var label_delay: float = 0.2
var fade_out_distance: float = 100

# Place holder still no assets
var line_sound = preload("res://assets/sounds/line_pop.wav")


async func _ready():
	back_button.pressed.connect(_on_back_pressed)
	_setup_background()
	_populate_credits()
	scroll_container.scroll_vertical = 0
	await get_tree().process_frame
	set_process(true)
	await _fade_in_labels()


func _setup_background():
	var gradient = Gradient.new()
	gradient.colors = [Color(0.95,0.95,1), Color(0.8,0.9,1)]
	var grad_tex = GradientTexture.new()
	grad_tex.gradient = gradient
	background.texture = grad_tex


func _populate_credits():
	credits_vbox.custom_constants.separation = 10
	for line in credit_lines:
		var panel = Panel.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.rect_min_size = Vector2(0, 40)

		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.98, 0.98, 0.98)
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		panel.add_theme_stylebox_override("panel", style)

		panel.modulate.a = 0  # invisible initially

		var label = Label.new()
		label.text = line
		label.align = Label.ALIGN_CENTER
		label.valign = Label.V_ALIGN_CENTER
		label.custom_fonts/font = preload("res://assets/fonts/Poppins-Regular.tres")
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_FILL
		panel.add_child(label)

		credits_vbox.add_child(panel)


async func _fade_in_labels():
	for i in range(credits_vbox.get_child_count()):
		var panel = credits_vbox.get_child(i)
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(panel, "modulate:a", 0, 1, fade_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT, i * label_delay)
		tween.start()

		if line_sound:
			await get_tree().create_timer(i * label_delay).timeout
			var snd = AudioStreamPlayer.new()
			snd.stream = line_sound
			add_child(snd)
			snd.play()


func _process(delta):
	scroll_container.scroll_vertical += scroll_speed * delta
	var max_scroll = credits_vbox.rect_size.y - scroll_container.rect_size.y
	if scroll_container.scroll_vertical >= max_scroll:
		scroll_container.scroll_vertical = max_scroll
		set_process(false)


	for panel in credits_vbox.get_children():
		var global_y = panel.get_global_position().y - scroll_container.get_global_position().y
		if global_y < fade_out_distance:
			panel.modulate.a = clamp(global_y / fade_out_distance, 0, 1)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
