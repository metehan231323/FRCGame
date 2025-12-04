extends Node

static func concatPrint(... args : Array):
	var message: String = ", ".join(args.map(str))
	print(message);

static func require() -> Array[Dictionary]:
	return [{}];
