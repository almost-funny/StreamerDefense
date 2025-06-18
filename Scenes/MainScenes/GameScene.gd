extends Node2D

signal game_finished(result, waves_survived)

var map_node

var build_mode = false
var build_valid = false
var wave_active = false
var build_tile
var build_location
var build_type

var current_wave = 0
var enemies_in_wave = 0
var waves_survived = 0
var wave_over = false

var base_health = 100

var gold = 100

var build_buttons = []


func _ready():
	for child in get_tree().get_nodes_in_group("build_buttons"):
		print("Found build button:", child.name)
		build_buttons.append(child)
		child.connect("pressed", self, "initiate_build_mode", [child.get_name()])
	map_node = get_node("Map1") ## Turn this into variable based on selected map
	update_gold_label()
	set_build_buttons_enabled(true)
	get_node("UI/HUD/GameControls/NextWaveButton").connect("pressed", self, "on_next_wave_button_pressed")
	get_node("UI/HUD/GameControls/NextWaveButton").visible = true

func _process(delta):
	if build_mode:
		update_tower_preview()

func _input(event):
	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode == true:
		verify_and_build()
		cancel_build_mode()


##
## Wave Functions
##
func start_next_wave():
	wave_over = false
	wave_active = true
	set_build_buttons_enabled(false)
	var wave_data = retrieve_wave_data()
	yield(get_tree().create_timer(0.2),"timeout") ## padding between waves so they don't start instantly
	spawn_enemies(wave_data)

func retrieve_wave_data():
	if current_wave < GameData.waves.size():
		var wave_data = GameData.waves[current_wave]
		current_wave += 1
		enemies_in_wave = wave_data.size()
		print("Spawning wave", current_wave, "with", enemies_in_wave, "enemies")
		return wave_data
	else:
		emit_signal("game_finished", true, waves_survived)
		return[]
	
func spawn_enemies(wave_data):
	for i in wave_data:
		var new_enemy = load("res://Scenes/Enemies/" + i[0] + ".tscn").instance()
		new_enemy.connect("base_damage", self, "on_base_damage")
		new_enemy.connect("enemy_died", self, "on_enemy_died")
		map_node.get_node("Path").add_child(new_enemy, true)
		yield(get_tree().create_timer(i[1]),"timeout")

func on_base_damage(damage):
	enemies_in_wave -= 1
	print("base_damage: enemies_in_wave now", enemies_in_wave)
	base_health -= damage
	if base_health <= 0:
		emit_signal("game_finished", false, waves_survived)
	else:
		get_node("UI").update_health_bar(base_health)
		if enemies_in_wave <= 0:
			end_wave()

func on_enemy_died():
	enemies_in_wave -= 1
	print("enemy_died: enemies_in_wave now", enemies_in_wave)
	if not wave_over:
		gold += 10
		update_gold_label()
	if enemies_in_wave <= 0:
		end_wave()

func end_wave():
	if wave_over:
		return
	wave_over = true
	wave_active = false
	waves_survived += 1
	print("END_WAVE called")
	if current_wave >= GameData.waves.size():
		emit_signal("game_finished", true, waves_survived)
	else:
		# Move to build phase
		set_build_buttons_enabled(true)
		get_node("UI/HUD/GameControls/NextWaveButton").visible = true	

func on_next_wave_button_pressed():
	get_node("UI/HUD/GameControls/NextWaveButton").visible = false
	set_build_buttons_enabled(false)  # Or set build_mode = false and cancel build preview
	wave_active = true
	start_next_wave()	


##
## Building Functions
##

func set_build_buttons_enabled(enabled):
	for button in build_buttons:
		button.disabled = not enabled

func initiate_build_mode(tower_type):
	if wave_active:
		return
	if build_mode:
		cancel_build_mode()
		set_build_buttons_enabled(true)
	build_type = tower_type + "T1"
	build_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())

func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").world_to_map(mouse_position)
	var tile_position = map_node.get_node("TowerExclusion").map_to_world(current_tile)
	var tower_cost = GameData.tower_data[build_type]["cost"]
	
	var can_build_here = map_node.get_node("TowerExclusion").get_cellv(current_tile) == -1
	var can_afford = gold >= tower_cost
	
	if can_build_here and can_afford:
		get_node("UI").update_tower_preview(tile_position, "ad54ff3c")
		build_valid = true
		build_location = tile_position
		build_tile = current_tile	
	else:
		get_node("UI").update_tower_preview(tile_position, "adff4545")
		build_valid = false
	
func cancel_build_mode():
	build_mode = false
	build_valid = false
	get_node("UI/TowerPreview").free()

func verify_and_build():
	if build_valid:
		var tower_cost = GameData.tower_data[build_type]["cost"]
		if gold >= tower_cost:
			gold -= tower_cost
			update_gold_label()
			var new_tower = load("res://Scenes/Turrets/" + build_type + ".tscn").instance()
			new_tower.position = build_location
			new_tower.built = true
			new_tower.type = build_type
			new_tower.category = GameData.tower_data[build_type]["category"]
			map_node.get_node("Turrets").add_child(new_tower, true)
			map_node.get_node("TowerExclusion").set_cellv(build_tile, 5)


##
## Gold Functions
##
func update_gold_label():
	get_node("UI/HUD/InfoBar/H/Money").text = str(gold)
