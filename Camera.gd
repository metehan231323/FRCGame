extends Camera2D

signal CameraStepped;
@export var CurrentFocus : Node2D;
@export var debugMode : bool = false;
var currentClbk : Callable;
var null_voidClbk = Callable.create(func(): pass, StringName("null_void"));

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
	stepCam();
	if currentClbk != null_voidClbk || currentClbk == null:
		CameraStepped.emit();
