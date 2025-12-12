# linter:disable
extends Node2D


# STATE MACHINES:
"""
 0: Random wander, never follow player
 1: Lock on to player and follow?
 2: Scriptable
"""

class_name BaseEnemy;

signal StateMachineChanged(state : int);
signal OnDestroyed;	
signal OnAdded(internalname, sprite, stateLevel);
		
static var UUIDIndex : int = 0;

static var EnemyDict = {};
# The internal name of the enemy class.		
var internalname = "OnlyTwentyCharacters";
# UUID of the enemy.
var enemyID = 0;
# The current sprite of the enemy.
var Sprite = null;
# Determines the current state machine of the target enemy. Do not change this via setting it directly, use ChangeStateMachine instead.
var FiniteStateMachine = 0;

func _init(Enemyname : String, sprite : Sprite2D, StateMachineLevel : int):
	internalname = Enemyname;
	Sprite = sprite;
	StateMachineLevel = StateMachineLevel;
	enemyID = UUIDIndex;
	UUIDIndex += 1;
	OnAdded.emit(name, Sprite, StateMachineLevel);
	if StateMachineLevel < 2:
		self.InitPathfind(StateMachineLevel);
	else:
		self.InitScriptableWithClass("SomeEnemyClass");

		
func InitScriptableWithClass(ClassName : String):
	pass
	
	
func ChangeStateMachine(state : int) -> void:
	if state in [0,1,2]:
		self.FiniteStateMachine = state;
		StateMachineChanged.emit(state);
	else: 
		push_error("Invalid state machine");
		
func dumpInfo():
	Global.concatPrint(self.enemyID, self.internalname, self.FiniteStateMachine);
		
func InitPathfind(StateMachineLevel : int):
	var currentstate = StateMachineLevel;
	StateMachineChanged.connect(func(state): currentstate = state);
	while true:
		await get_tree().create_timer(1.0).timeout; # wait 1 sec
		print("pathfind tick!");
		
		

func destroy() -> void:
	self.queue_free();	
	OnDestroyed.emit();	
