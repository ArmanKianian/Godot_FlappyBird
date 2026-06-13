extends Node2D

@onready var pipe_lines: Node2D = $pipe_lines
@onready var bird: CharacterBody2D = $bird

const pipe_line = preload("uid://dy457qe0pnng7")
const pipe_head = preload("uid://b0wwwib02nbby")
const pipe_tail = preload("uid://virdvbudwf1a")

@onready var score: Label = $UI/Score
@onready var best: Label = $UI/Best

var speed: int = 5

func _ready() -> void:
	score.text = "0"

func _process(_delta: float) -> void:
	bird.velocity.x = 0
	for child in pipe_lines.get_children():
		child.position.x += -speed
		
		# Free pipe_line if it's out of screen
		if child.position.x <= -608 - 64:
			child.queue_free()
		
		# Add score
		if child.position.x <= int(bird.position.x) and child.position.x + speed > int(bird.position.x):
			score.text = str(int(score.text) + 1)

func spawn_pipe_line():
	var new_pipe_line = pipe_line.instantiate()
	new_pipe_line.position.x = 608 + 32
	new_pipe_line.position.y = -288
	
	# Add Pipe Tails
	for i in range(10):
		var new_pipe_tail = pipe_tail.instantiate()
		new_pipe_tail.position.y = i * 64
		new_pipe_line.add_child(new_pipe_tail)
	var hole = randi_range(2, 8)
	
	# Delete 4 Pipe Tails in a row randomly
	new_pipe_line.get_child(hole-2).queue_free()
	new_pipe_line.get_child(hole-1).queue_free()
	new_pipe_line.get_child(hole).queue_free()
	new_pipe_line.get_child(hole+1).queue_free()
	
	# Add Pipe Heads at the end of each Pipe Tail cut
	var pos = new_pipe_line.get_child(hole).position
	var new_pipe_head = pipe_head.instantiate()
	new_pipe_head.position = pos + Vector2(0, -16 - 64 -64)
	new_pipe_line.add_child(new_pipe_head)
	new_pipe_head = pipe_head.instantiate()
	new_pipe_head.position = pos + Vector2(0, 16 + 64)
	new_pipe_head.rotation_degrees = 180
	new_pipe_line.add_child(new_pipe_head)
	pipe_lines.add_child(new_pipe_line)

func restart():
	best.text = str(max(int(score.text), int(best.text)))
	score.text = "0"
	for child in pipe_lines.get_children():
		child.queue_free()
	bird.position = Vector2(-500, -16)
	bird.velocity = Vector2.ZERO

func _on_timer_timeout() -> void:
	spawn_pipe_line()
	if bird.position.x < -608 - 64:
		restart()
