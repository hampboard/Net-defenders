# res://scripts/game_manager.gd
extends Node

var scenarios = []
var playthrough_set = []
var has_retried = false
var current_index = 0
var waiting_for_feedback = false
var current_difficulty: String = "easy"

@onready var scenario_card = $ScenarioCard
@onready var feedback_label = $FeedbackLabel
@onready var feedback_anim = $FeedbackLabel/FeedbackAnim
@onready var menu_buttons = $MenuButtons
@onready var retry_button = $MenuButtons/Retry
@onready var easy_button = $MenuButtons/Easy
@onready var medium_button = $MenuButtons/Medium
@onready var hard_button = $MenuButtons/Hard
@onready var return_button = $MenuButtons/Return

func _ready():
	randomize()
	load_scenarios()
	feedback_label.visible = false
	menu_buttons.visible = false

	# Connect signals
	feedback_anim.animation_finished.connect(_on_FeedbackAnim_animation_finished)
	retry_button.pressed.connect(retry_playthrough)
	easy_button.pressed.connect(func(): change_difficulty("easy"))
	medium_button.pressed.connect(func(): change_difficulty("medium"))
	hard_button.pressed.connect(func(): change_difficulty("hard"))
	return_button.pressed.connect(go_to_main_menu)

	# Start using the difficulty from GlobalState
	current_difficulty = GlobalState.selected_difficulty
	start_playthrough(current_difficulty)
	show_next_scenario()

func load_scenarios():
	var file = FileAccess.open("res://data/scenarios.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		if typeof(data) == TYPE_ARRAY:
			scenarios = data
		else:
			push_error("JSON is not an array")
	else:
		push_error("Could not open scenarios.json")

func get_playthrough_set(difficulty: String, count: int = 10) -> Array:
	var filtered = scenarios.filter(func(item): return item["difficulty"] == difficulty)
	filtered.shuffle()
	return filtered.slice(0, min(count, filtered.size()))

func start_playthrough(difficulty: String):
	current_difficulty = difficulty
	playthrough_set = get_playthrough_set(difficulty, 10)
	current_index = 0
	has_retried = false
	menu_buttons.visible = false
	feedback_label.visible = false


func randomize_scenario(original: Dictionary) -> Dictionary:
	var q = original.duplicate(true)
	var paired: Array = []
	
	for i in q.choices.size():
		paired.append({
			"text": q.choices[i],
			"is_correct": i == q.correct_index
		})
	
	paired.shuffle()
	
	q.choices.clear()
	for i in paired.size():
		q.choices.append(paired[i].text)
		if paired[i].is_correct:
			q.correct_index = i
	
	return q

func retry_playthrough():
	# single retry policy; remove the guard if you want unlimited retries
	if not has_retried:
		current_index = 0
		has_retried = true
		playthrough_set = get_playthrough_set(current_difficulty, 10)
		scenario_card.visible = false
		menu_buttons.visible = false
		show_next_scenario()
	else:
		feedback_label.text = "⚠️ You already retried once."
		feedback_label.visible = true
		feedback_anim.play("ShowFeedback")

func change_difficulty(new_difficulty: String):
	GlobalState.selected_difficulty = new_difficulty
	start_playthrough(new_difficulty)
	scenario_card.visible = false
	menu_buttons.visible = false
	show_next_scenario()

func show_next_scenario():
	if current_index >= playthrough_set.size():
		show_end_message()
		return
	var scenario = playthrough_set[current_index]
	

	var randomized = randomize_scenario(scenario)
	
	scenario_card.visible = true
	scenario_card.set_scenario(randomized, Callable(self, "_on_answer_chosen"))

func _on_answer_chosen(scenario: Dictionary, correct: bool):
	if correct:
		feedback_label.text = scenario.get("feedback_correct", "Correct")
	else:
		feedback_label.text = scenario.get("feedback_incorrect", "Incorrect")
	feedback_label.visible = true
	waiting_for_feedback = true
	feedback_anim.play("ShowFeedback")

func _on_FeedbackAnim_animation_finished(_anim_name: String) -> void:
	if waiting_for_feedback:
		feedback_label.visible = false
		await get_tree().create_timer(0.3).timeout
		current_index += 1
		scenario_card.visible = false
		waiting_for_feedback = false
		show_next_scenario()

func show_end_message():
	feedback_label.text = "🎉 You’ve finished all scenarios! Choose an option."
	feedback_label.visible = true
	feedback_anim.play("ShowFeedback")
	menu_buttons.visible = true

func go_to_main_menu():
	# optional cleanup if needed
	menu_buttons.visible = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
