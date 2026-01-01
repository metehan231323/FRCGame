extends Node

@onready var FadeOutLayer = $Camera2D/FadeOutLayer;
@onready var FadeRect = $Camera2D/FadeOutLayer/FadeRect;
@onready var FadePlayer = $Camera2D/FadeOutLayer/FadePlayer;
@onready var Background = $Background;

func _ready() -> void:
	var clbk1 = func():
		if get_node("Player"):
			var player = get_node("Player");
			player.set("Speed", 0);
			get_tree().create_timer(0.5).timeout.connect(func():
				player.set("Speed", 100);	
			);
		else:
			# the player somehow got nuked i dunno? d
			push_error("Player not found");
	var clbk2 = func():
		if get_node("Player"):
			var player = get_node("Player");
			player.set("Speed", 0);
			print("speed set to 0");
			get_tree().create_timer(0.5).timeout.connect(func():
				player.set("Speed", 100);	
			);
		else:
			push_error("Player not found");
	FadeTransition.changeclbk(FadeTransition.TransitionType.OTHER, clbk1);
	FadeTransition.changeclbk(FadeTransition.TransitionType.ROOM_TRANSITION, clbk2);
	FadeTransition.supply(FadeRect, FadePlayer);
		
	
