@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:

	print( str_to_color("(0, 0, 0.435, 1)") )
	
	
	#print(Color("(0, 0, 0, 1)"))

func str_to_color(str: String) -> Color:
	var color_string = "(0, 0, 0.435, 1)"
	var new_string = color_string.erase(0).erase(len(color_string) - 2)
	var split = new_string.split(",")
	var new_color = Color(float(split[0]), float(split[1]), float(split[2]), float(split[3]))
	return new_color
