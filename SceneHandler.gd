extends Node

func _ready():
	load_main_menu()

func load_main_menu():
	if has_node("MainMenu"):
		get_node("MainMenu").queue_free()
	var main_menu = load("res://Scenes/UIScenes/MainMenu.tscn").instance()
	main_menu.name = "MainMenu"
	add_child(main_menu)
	main_menu.get_node("M/VB/NewGame").connect("pressed", self, "on_new_game_pressed")
	main_menu.get_node("M/VB/Quit").connect("pressed", self, "on_quit_pressed")

func on_new_game_pressed():
	if has_node("MainMenu"):
		get_node("MainMenu").queue_free()
	var game_scene = load("res://Scenes/MainScenes/GameScene.tscn").instance()
	game_scene.name = "GameScene"
	game_scene.connect("game_finished", self, "on_game_finished")
	add_child(game_scene)

func on_quit_pressed():
	get_tree().quit()

func on_game_finished(result, waves_survived):
	print("on_game_finished called! Result:", result, "waves:", waves_survived)
	if has_node("GameScene"):
		get_node("GameScene").queue_free()
	var end_screen = load("res://Scenes/UIScenes/EndScreen.tscn").instance()
	end_screen.name = "EndScreen"
	add_child(end_screen)
	end_screen.set_results(result, waves_survived)
	end_screen.connect("play_again", self, "on_play_again")
	end_screen.connect("go_to_menu", self, "on_main_menu")

func on_play_again():
	if has_node("EndScreen"):
		get_node("EndScreen").queue_free()
	on_new_game_pressed()

func on_main_menu():
	if has_node("EndScreen"):
		get_node("EndScreen").queue_free()
	load_main_menu()
