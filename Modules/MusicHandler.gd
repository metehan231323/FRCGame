extends Node

var currentBGTrack : AudioStreamMP3;
var InitTrack : AudioStreamMP3;
@onready var BGMusicPlayer : AudioStreamPlayer2D = $".";

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	# BGMusicPlayer.play();

# Sets the background music 
func setBgMusic(Track : AudioStreamMP3, fade : bool) -> void:
	currentBGTrack = Track;
	
