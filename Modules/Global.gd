extends Node

static func concatPrint(... args : Array):
	var message: String = ", ".join(args.map(str));
	print(message);
	
func wait(time : float) -> void:
	await get_tree().create_timer(time).timeout
	return
	
func BlurImage(spr2d : Sprite2D) -> Sprite2D:
	var newimgblurred : Image = Image.new();
	var path = spr2d.get_path();
	var img = load(path).get_image();
	newimgblurred.copy_from(img);
	newimgblurred.resize(64,36, Image.INTERPOLATE_TRILINEAR);
	var text = ImageTexture.create_from_image(newimgblurred);
	var newsprite = Sprite2D.new();
	newsprite.texture = text;
	return newsprite
	
	
