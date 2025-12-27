extends CharacterBody2D

signal onStateChanged(state);
enum state {WANDER, CHASE, DEAD};
var WanderSpeed : int = 60;
var ChaseSpeed : int = 90;
@export var CurrentSpeed = 60;
@export var gravityprone : bool = true;
@export var gravity : int = 300;
@export var CurrentState : state = state.WANDER;
@export var direction : int = 1; #1 represents right, -1 is left
@onready var SightRay : RayCast2D = $SightRay;
@onready var GroundRay : RayCast2D = $GroundRay;
@onready var Model : Sprite2D = $Model;
@onready var Animator : AnimationPlayer = $Animator;

func onPlayerJumpedOn() -> void:
	if Animator.is_playing():
		Animator.stop();
		Animator.play("Dying");
	
# Signal clbk
func onstateChanged(newstate : state) -> void:
	match newstate:
		state.CHASE:
			
			self.CurrentSpeed = ChaseSpeed;
		state.WANDER:
			self.CurrentSpeed = WanderSpeed;
		state.DEAD:
			queue_free();
			
# Changes the state of the snake and returns the old state.
func changeState(newstate) -> state:
	var oldState = CurrentState;
	self.CurrentState = newstate;
	return oldState;

func wander() -> void:
	if not Animator.current_animation != "Crawling":
		Animator.play("Crawling");
	var SeesPlayer = lookforPlayer();
	var SeesCliffOnWander = lookforCliff();
	# Ignore player, the cliff is lowkey more important anyway
	if SeesPlayer == true and SeesCliffOnWander == true:
		flip();
	elif SeesPlayer == true and SeesCliffOnWander == false:
		pass
	velocity.x = CurrentSpeed * direction;
	
# Flips the model and direction of the snake.
func flip() -> void:
	Model.flip_h = not Model.flip_h;
	match direction:
		1:
			direction = -1;
		-1:
			direction = 1;

# Casts the ray to look for the player.
func lookforPlayer() -> bool:
	var collider = SightRay.get_collider();
	if collider and collider.name == "Player":
		changeState(state.CHASE);
		onStateChanged.emit(state.CHASE);
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
	# The dying of the snake IS tied to the animation.
	Animator.animation_finished.connect(func(anim_name):
		if anim_name == "Dying":
			onStateChanged.emit(state.DEAD)
	)

func _physics_process(delta: float) -> void:
	if self.CurrentState != state.CHASE:
		wander();
		
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()
