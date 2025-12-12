extends Node2D

@onready var Bottom = $Realblok/Alt

func _ready() -> void:
	Bottom.area_entered.connect(AreaEnteredClbk)


func AreaEnteredClbk(area : Area2D) -> Node:
	if area.name == "PlayerHitbox":
		print("Player hit block")
		return area.get_parent()
	else:
		return null
