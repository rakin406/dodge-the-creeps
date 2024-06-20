extends Area2D

signal hit

# Threshold distance to stop movement (for mobile)
const STOPPING_DISTANCE: float = 1.0

@export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size: Vector2 # Size of the game window.
var is_mobile: bool      # Boolean for mobile platform
var mouse_pos: Vector2   # Mouse click position


# Called when the node enters the scene tree for the first time.
func _ready():
	hide() # Fix player appearing in title screen
	screen_size = get_viewport_rect().size
	
	match OS.get_name():
		"Android", "iOS":
			is_mobile = true
		_:
			is_mobile = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	
	if is_mobile:
		# Update mouse click position
		if Input.is_action_pressed("mouse_click"):
			mouse_pos = get_global_mouse_position()
		
		if position.x < mouse_pos.x:
			velocity.x += 1
		if position.x > mouse_pos.x:
			velocity.x -= 1
		if position.y < mouse_pos.y:
			velocity.y += 1
		if position.y > mouse_pos.y:
			velocity.y -= 1
	else:
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1

	# Choose animation based on player direction
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

	# Check whether the player is moving
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed # Prevent fast diagonal movement
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	if is_mobile:
		position = position.move_toward(mouse_pos, delta * speed)
	else:
		position += velocity * delta
	
	position = position.clamp(Vector2.ZERO, screen_size)


func _on_body_entered(_body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)


## Reset the player.
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
