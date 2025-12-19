extends Node

static func concatPrint(... args : Array):
	var message: String = ", ".join(args.map(str))
	print(message);
	
func wait(time : float) -> void:
	await get_tree().create_timer(time).timeout
	return
