extends RefCounted # so that class cannot get freed
class_name ModuleLoader

static func load_module(scriptpath : String) -> Dictionary:
	var module = load(scriptpath);
	var returns = {};
	
	if not module or module is not GDScript:
		push_error("The path given is invalid or the instance is not a script")
		return {}
	else:
		var instance : GDScript = module.new();
		var methods : Array[Dictionary] = instance.get_script_method_list();
		for method in methods:
			var methodname = method["name"];
			if methodname.begins_with("_") or methodname == "set" or methodname == "get":
				pass
			else:
				returns[methodname] = Callable(instance, methodname)
				
		returns["_instance"] = module
		return returns
		
	
