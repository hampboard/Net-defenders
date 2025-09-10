extends Node2D

@onready var play_button = $MenuButtons/PlayButton
@onready var difficulty_select = $MenuButtons/DifficultySelect
@onready var quit_button = $MenuButtons/QuitButton
@onready var credits_button = $MenuButtons/CreditsButton
@onready var warning_popup = $WarningPopup

var chosen_difficulty: String = ""

func _ready():
	difficulty_select.clear()
	difficulty_select.add_item("Easy")
	difficulty_select.add_item("Medium")
	difficulty_select.add_item("Hard")
	difficulty_select.text = "Difficulty"

	play_button.pressed.connect(_on_play_pressed)
	difficulty_select.item_selected.connect(_on_difficulty_selected)
	quit_button.pressed.connect(_on_quit_pressed)
	credits_button.pressed.connect(_on_credits_pressed)

func _on_play_pressed():
	if chosen_difficulty == "":
		warning_popup.popup_centered()
		return
	get_tree().change_scene_to_file("res://Scenes/GameScreen.tscn")

func _on_difficulty_selected(index: int):
	chosen_difficulty = difficulty_select.get_item_text(index)

func _on_quit_pressed():
	get_tree().quit()

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")
