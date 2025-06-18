extends Node

var tower_data = {
	"GunT1": {
		"damage": 20,
		"rof": 0.3,
		"range": 350,
		"cost": 50,
		"category": "Projectile"},
	"MissileT1": {
		"damage": 100,
		"rof": 3,
		"range": 550,
		"cost": 100,
		"category": "Missile"}}


var waves = []

func _ready():
	generate_waves(999)

func generate_waves(num_waves):
	randomize()
	for i in range(num_waves):
		var count = 5 + i * 5
		var wave = []
		for j in range(count):
			var delay = rand_range(0.1, 1.0)
			wave.append(["BlueTank", delay])
		waves.append(wave)
