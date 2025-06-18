extends Control

signal play_again
signal go_to_menu

func _ready():
	get_node("M/VBoxContainer/ResultsLabel/HBoxContainer/PlayAgain").connect("pressed", self, "on_play_again_pressed")
	get_node("M/VBoxContainer/ResultsLabel/HBoxContainer/MainMenu").connect("pressed", self, "on_main_menu_pressed")

func set_results(won, waves_survived):
	if won:
		get_node("M/VBoxContainer/MainLabel").text = "You Win!"
	else:
		get_node("M/VBoxContainer/MainLabel").text = "You Lose!"
	var plural = ""
	if waves_survived != 1:
		plural = "s"
	get_node("M/VBoxContainer/ResultsLabel").text = "You survived %d wave%s!" % [waves_survived, plural]

func on_play_again_pressed():
	emit_signal("play_again")

func on_main_menu_pressed():
	emit_signal("go_to_menu")
