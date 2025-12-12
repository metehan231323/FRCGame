extends CharacterBody2D

@export var speed : int = 300;
@export var gravity : int = 300;
@export var gravityprone = true; # controls gravity
@export var onfloor : bool;
@export var Enemy : BaseEnemy = BaseEnemy.new("BaseEnemy", self.sprite, 0)
@onready var sprite = $Model;
@onready var HeadArea = $HeadArea
const movespeed = 200.0;
var RNG : RandomNumberGenerator = RandomNumberGenerator.new();

func _ready() -> void:
	Enemy.InitPathfind(0);

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if self.gravityprone == true:
		if not is_on_floor():
			onfloor = false;
			velocity += Vector2(0, gravity * delta); 
		else:
			onfloor = true;
	else:
		print("gravity currently nullified");
		velocity.y = 0;

	var dir = RNG.randi_range(1, 2);
	var direction : float = 0.0;
	if dir == 1:
		direction = -1.0
	else: 
		direction = 1.0
		
	

	move_and_slide()
