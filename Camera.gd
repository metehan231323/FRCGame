extends Camera2D

signal CameraStepped;
signal CutsceneShifted;
@export var CurrentFocus : Node2D;
@export var debugMode : bool = false;
var currentClbk : Callable;
var null_voidClbk : Callable = Callable.create(func(): pass, StringName("null_void"));
var cutsceneActive : bool = false;

func _ready() -> void:
	print("Camera initialized"); 
	CurrentFocus = $"../CharacterBody2D";
	CameraStepped.connect(func(): if currentClbk.is_valid(): currentClbk.call());

# Changes the focus of the camera to a new Node2D.
#@NewObj --> Node2D
func changeFocus(NewObj : Node2D) -> void:
	CurrentFocus = NewObj;
	
# Serializes a Vector2 into 2 strings.
#@Vec2 --> Vector2	
func serializeVec2(Vec2 : Vector2) -> String:
	var xcom = Vec2.x;
	var ycom = Vec2.y;
	return str(xcom) + str(ycom);

func stepCam() -> void:
	var CurrentFocusPos = CurrentFocus.position;
	self.position = Vector2(CurrentFocusPos.x, CurrentFocusPos.y + 10)
	if debugMode == true:
		print("new pos: " + serializeVec2(self.position));
	
	
func setSteppedclbk(function : Callable) -> void:
	currentClbk = function;
	
func clearSteppedclbk() -> void:
	currentClbk = null_voidClbk;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if debugMode == true:
		print("time since last render: " + str(delta));
	stepCam();
	if currentClbk != null_voidClbk || currentClbk == null:
		CameraStepped.emit();
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event.pressed.connect(func(): CutsceneShifted.emit());
		
# lerp opacity or some shit idk, dont overlay a pic though
func Transition(current : Image, next : Image, transitiontime : float) -> void:
	pass

# Initializes a cutscene with minimum wait time between images "mintime", and images "...". The mintime determines the amount of seconds inputs will be ignored for each picture. Each picture will fade in and out.
func InitCutscene(mintime : float, ... args : Array) -> void:
	cutsceneActive = true;
	var lambdavars = {"index" : 0, "currentImg" : args[0], "nextimg" : null, "transitionready" : true};
	#var index : int = 0;
	#var currentImg : Image = args[0];
	#var nextimg : Image = null;
	#var transitionready = true;
	
	var lambda : Callable = func(): 
		lambdavars["index"] += 1;
		lambdavars["currentImg"] = args[lambdavars["index"]];
		# terminate if out of bounds of array
		if lambdavars["index"] + 1 > len(args):
			cutsceneActive = false;
			return;
		lambdavars["nextimg"] = args[lambdavars["index"] + 1];
		Transition(lambdavars["currentImg"], lambdavars["nextimg"], 1.0);
		
	CutsceneShifted.connect(lambda);
	

	
