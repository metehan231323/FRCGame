extends CharacterBody2D


@export var speed : int = 85;
@export var gravity : int = 300;
@export var jumpforce : int = 200;
@export var hasDoubleJump : bool = false;
@export var Health : int = 3;
@export var gravityprone = true; # controls gravity
@export var iframes = false; # controls if char has iframes
@onready var sprite = $Model;
@onready var HurtBox = $Model/HurtArea/Hurtbox;
@onready var HurtArea = $Model/HurtArea;
@onready var Cam = $"../Camera2D";
@onready var DeathZone = $"../DeathZone";
var TimesJumped : int = 0;
var onfloor = null;
var jumpedfromvalid = false; # if the player jumped from a surface (aka they can bypass the check to see if they're on a surface to double jump)

func connectListeners() -> void:
	DeathZone.area_entered.connect(area_entered_clbk);
	
func GameOver() -> void:
	print("Game Over");	
	get_tree().reload_current_scene();
	
func area_entered_clbk(area : Area2D) -> void:
	if area.name == "HurtArea":
		GameOver();
	
	
func _ready() -> void:
	add_to_group("Player");
	connectListeners();
	print("Connected signals");
	# FadeTransition.transition(FadeTransition.TransitionType.OTHER);
	
	# Cam.setSteppedclbk(func(): print("this is from the clbk"));
	# await get_tree().create_timer(2.0).timeout;
	# Cam.clearSteppedclbk();
	# print("cleared clbk now!");

# Gives character iframes.
func enableIFrames(timeout : float = 2.0) -> void:
	self.iframes = true;
	get_tree().create_timer(timeout).timeout.connect(func(): self.iframes = false);

func _input(keyevent : InputEvent) -> void:
	if keyevent.as_text() == "P":
		get_tree().reload_current_scene();
	
func takeDamage(amount : int, triggeriframes : bool = true, iframetime : float = 1.0) -> void:
	if iframes == false:
		self.Health -= amount;
		if self.Health <= 0:
			GameOver();
		if triggeriframes == true:
			enableIFrames(iframetime);
		
		
func applyKnockback(direction : Vector2, strength : float) -> void: 
	velocity = direction * strength
	move_and_slide()
	
# Handles all jump states
func processJump() -> void:
	if Input.is_action_just_pressed("jump"):
		if onfloor == false:
			if hasDoubleJump == true and TimesJumped == 0:
				velocity.y = -jumpforce;
				TimesJumped += 1;
			elif jumpedfromvalid == true:
				velocity.y = -jumpforce;
				TimesJumped += 1;
				jumpedfromvalid = false;
		else:
			if hasDoubleJump == false and TimesJumped == 0:
				velocity.y = -jumpforce;
				TimesJumped += 1;
			elif hasDoubleJump == true and TimesJumped < 2:
				velocity.y = -jumpforce
				TimesJumped += 1;
				jumpedfromvalid = true;
		
func _physics_process(delta: float) -> void:
	if self.gravityprone == true:
		if not is_on_floor():
			onfloor = false;
			velocity += Vector2(0, gravity * delta); 
		else:
			onfloor = true;
			TimesJumped = 0;
	else:
		print("gravity currently nullified");
		velocity.y = 0;
	
	# Handle jump.
	processJump();
	
	var direction := Input.get_axis("move_left", "move_right");
	if direction:
		match direction:
			-1.0:
				sprite.flip_h = false;
			1.0:
				sprite.flip_h = true;
				
		velocity.x = direction * speed;
	else:
		velocity.x = move_toward(velocity.x, 0, speed);
		
	move_and_slide();

	
	
