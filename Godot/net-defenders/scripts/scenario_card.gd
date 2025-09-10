extends Control

@onready var scenario_label = $CardPanel/VBox/ScenarioText
@onready var buttons = [
	$CardPanel/VBox/ChoiceButton1,
	$CardPanel/VBox/ChoiceButton2,
	$CardPanel/VBox/ChoiceButton3
]
@onready var anim_player = $AnimPlayer

var current_scenario: Dictionary = {}
var callback: Callable = Callable()

func set_scenario(data: Dictionary, on_answer: Callable) -> void:
	current_scenario = data
	callback = on_answer
	
	scenario_label.text = data["scenario"]
	
	for i in range(buttons.size()):
		if i < data["choices"].size():
			buttons[i].text = data["choices"][i]
			buttons[i].visible = true
			
			if buttons[i].is_connected("pressed", _on_choice_pressed):
				buttons[i].disconnect("pressed", _on_choice_pressed)
			
			buttons[i].connect("pressed", _on_choice_pressed.bind(i))
		else:
			buttons[i].visible = false
	
	anim_player.play("SlideIn")

func _on_choice_pressed(choice_index: int) -> void:
	var correct: bool = (choice_index == current_scenario["correct_index"])
	

	anim_player.play("SlideOut")
	

	await anim_player.animation_finished
	
	if callback.is_valid():
		callback.call(current_scenario, correct)

func _ready():
	print("=== SCENARIO CARD DEBUG START ===")
	print("Children of ScenarioCard:", get_children())
	print("=== SCENARIO CARD DEBUG END ===")
