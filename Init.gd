extends Node

@onready var FadeOutLayer = $Camera2D/FadeOutLayer;
@onready var FadeRect = $Camera2D/FadeOutLayer/FadeRect;
@onready var FadePlayer = $Camera2D/FadeOutLayer/FadePlayer;

func _ready() -> void:
	FadeTransition.supply(FadeRect, FadePlayer);
