extends Node

var LineCache : Array[Line2D] = [];

static func concatPrint(... args : Array):
	var message: String = ", ".join(args.map(str));
	print(message);
	
func wait(time : float) -> void:
	await get_tree().create_timer(time).timeout
	return
	
func BlurImage(spr2d : Sprite2D) -> Sprite2D:
	var newimgblurred : Image = Image.new();
	var img = spr2d.texture.get_image();
	newimgblurred.copy_from(img);
	newimgblurred.resize(64,36, Image.INTERPOLATE_TRILINEAR);
	var text = ImageTexture.create_from_image(newimgblurred);
	var newsprite = Sprite2D.new();
	newsprite.texture = text;
	return newsprite
	
func visualizeRays(caller : Node, ... rays: Array) -> void:
	for line in LineCache:
		if is_instance_valid(line):
			line.queue_free();
	LineCache.clear();
	for ray in rays:
		if ray.get_class() == "RayCast2D":
			var newline = Line2D.new();
			# print("ray position " + str(ray.position));
			# aprint("ray target pos " + str(ray.target_position));
			newline.add_point(ray.position);
			newline.add_point(ray.target_position); 
			newline.width = 2;
			newline.default_color = Color(0.0, 0.0, 255.0); 
			caller.add_child(newline);
			LineCache.append(newline);
		else: 
			push_error("Arguments given were not raycasts.");

	
	
	
	
