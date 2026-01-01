extends CharacterBody2D

signal onStateChanged(state);
enum state {WANDER, CHASE, DEAD};
var WanderSpeed : int = 60;
var ChaseSpeed : int = 90;
var isonfloor = true;
@export var IgnorePlayer = false;
@export var DrawRaycasts : bool = false;
@export var CurrentSpeed = 60;
@export var gravityprone : bool = true;
@export var gravity : int = 300;
@export var CurrentState : state = state.WANDER;
@export var direction : int = 1; #1 represents right, -1 is left
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player");
@onready var SightRay : RayCast2D = $SightRay;
@onready var GroundRay : RayCast2D = $GroundRay;
@onready var Model : Sprite2D = $Model;
@onready var Animator : AnimationPlayer = $Animator;
@onready var HeadArea : Area2D = $HeadArea;
@onready var HitboxArea : Area2D = $HitboxArea;
@onready var snakeHiss : AudioStreamWAV = preload("res://assets/sounds/snake-hiss.wav");
@onready var Mouth : AudioStreamPlayer2D = $Mouth;
# target_position (x,y)/position (x,y) 
const GROUND_RIGHT_FLIP_VEC_POS = [45.0, 22.0, 115.0, 0.0];
const GROUND_LEFT_FLIP_VEC_POS = [-45.0, 22.0, 0.0, 0.0];
const SIGHT_LEFT_FLIP_VEC_POS = [-100, 0.0, 0.0, 0.0];
const SIGHT_RIGHT_FLIP_VEC_POS = [100.0, 0.0, 115.0, 0.0];
const KNOCKBACK_VECTOR = Vector2(1.0, 1.0);

func onPlayerJumpedOn() -> void:
	if Animator.is_playing():
		Animator.stop();
		Animator.play("Dying");
		
func onHeadEntered(area : Area2D) -> void:
	if area.name == "PlayerStomp":
		print("player hit a stomp");
		onPlayerJumpedOn(); 
	elif area.name == "Hurtbox":
		player.takeDamage(1, true, 1.0);
		print("player took damage supposedly");
		
func onHitboxEntered(body : PhysicsBody2D) -> void:
	if body.name == "Player":
		player.takeDamage(1, true, 1.0);
		player.applyKnockback(KNOCKBACK_VECTOR, 2.0);
	
# Signal clbk
func onstateChanged(newstate : state) -> void:
	match newstate:
		state.CHASE:
			print("starting chase");
			Mouth.play()
			self.CurrentSpeed = ChaseSpeed;
		state.WANDER:
			self.CurrentSpeed = WanderSpeed;
		state.DEAD:
			self.queue_free();
			
# Changes the state of the snake and returns the old state.
func changeState(newstate) -> state:
	var oldState = CurrentState;
	self.CurrentState = newstate;
	return oldState;
	
func flipRays(lr : int) -> void:
	match lr:
		1:		
			var comp1 = SIGHT_LEFT_FLIP_VEC_POS[0]; 
			var comp2 = SIGHT_LEFT_FLIP_VEC_POS[1]; 
			var comp3 = SIGHT_LEFT_FLIP_VEC_POS[2]; 
			var comp4 = SIGHT_LEFT_FLIP_VEC_POS[3]; 
			var comp5 = GROUND_LEFT_FLIP_VEC_POS[0];
			var comp6 = GROUND_LEFT_FLIP_VEC_POS[1];
			var comp7 = GROUND_LEFT_FLIP_VEC_POS[2];
			var comp8 = GROUND_LEFT_FLIP_VEC_POS[3];
			SightRay.target_position = Vector2(comp1, comp2);
			SightRay.position = Vector2(comp3, comp4);
			GroundRay.target_position = Vector2(comp5, comp6);
			GroundRay.position = Vector2(comp7, comp8);
		-1:
			var comp1 = SIGHT_RIGHT_FLIP_VEC_POS[0]; 
			var comp2 = SIGHT_RIGHT_FLIP_VEC_POS[1]; 
			var comp3 = SIGHT_RIGHT_FLIP_VEC_POS[2]; 
			var comp4 = SIGHT_RIGHT_FLIP_VEC_POS[3]; 
			var comp5 = GROUND_RIGHT_FLIP_VEC_POS[0];
			var comp6 = GROUND_RIGHT_FLIP_VEC_POS[1];
			var comp7 = GROUND_RIGHT_FLIP_VEC_POS[2];
			var comp8 = GROUND_RIGHT_FLIP_VEC_POS[3];
			SightRay.target_position = Vector2(comp1, comp2);
			SightRay.position = Vector2(comp3, comp4);
			GroundRay.target_position = Vector2(comp5, comp6);
			GroundRay.position = Vector2(comp7, comp8);
			
func drawRays() -> void:
	Global.visualizeRays(self, SightRay, GroundRay);DrawRaycasts = true;
	
func chase() -> void:
	velocity.x = CurrentSpeed * -direction;

func wander() -> void:
	if Animator.current_animation != "Crawling":
		Animator.play("Crawling");
	var SeesPlayer = lookforPlayer(); 
	var SeesCliffOnWander = lookforCliff();
	# Global.concatPrint(SeesPlayer, SeesCliffOnWander); 
	# Ignore player, the cliff is lowkey more important anyway
	if SeesPlayer == true and SeesCliffOnWander == true:
		flip();
	elif SeesPlayer == true and SeesCliffOnWander == false:
		if CurrentState != state.CHASE and IgnorePlayer == false: 
			changeState(state.CHASE);
			onStateChanged.emit(state.CHASE);
	elif SeesPlayer == false and SeesCliffOnWander == true:
		flip();
	else:
		pass
	velocity.x = CurrentSpeed * -direction;
	
# Flips the model and direction of the snake.
func flip() -> void:
	if isonfloor != false:
		Model.flip_h = not Model.flip_h;
		match direction:
			1:
				flipRays(-1);
				direction = -1;
			-1:
				flipRays(1);
				direction = 1;

# Casts the ray to look for the player
func lookforPlayer() -> bool:
	var collider = SightRay.get_collider();
	if collider and collider.name == "Player":
		return true
	else:
		return false

func lookforCliff() -> bool:
	var collider = GroundRay.get_collider();
	if not collider:
		return true
	else:
		return false

func _ready() -> void:
	DrawRaycasts = true;
	SightRay.collision_mask = 1;
	CurrentSpeed = 60; # Var keeps nulling for some reason.
	HeadArea.area_entered.connect(onHeadEntered);
	HitboxArea.body_entered.connect(onHitboxEntered);
	Animator.animation_finished.connect(func(anim_name):
		if anim_name == "Dying":
			onStateChanged.emit(state.DEAD)
	)

func _physics_process(delta: float) -> void:
	if DrawRaycasts == true:
		drawRays();
	isonfloor = self.is_on_floor();
	if self.CurrentState != state.CHASE:
		wander();
	elif self.CurrentState == state.CHASE:
		print("AAA CHASING")
		chase();print("found player");
			
	if not is_on_floor():
		velocity.y += gravity * delta;

	move_and_slide();
