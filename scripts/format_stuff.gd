extends GDScript

static func format_date_array(date: String) -> Array:
	var split = date.split("T")
	var time = [split[0], split[1].replace("Z", "")]
	
	print(time[0] + " " + time[1])
	return time

static func str_to_color(str: String) -> Color:
	var new_string = str.erase(0).erase(len(str) - 2)
	var split = new_string.split(",")
	var new_color = Color(float(split[0]), float(split[1]), float(split[2]), float(split[3]))
	return new_color
