extends RefCounted

static func format_date_array(date: String) -> PackedStringArray:
	var split = date.split("T")
	var time = [split[0], split[1].replace("Z", "")]
	
	print(time[0] + " " + time[1])
	return time

static func format_date_dict(dict: Dictionary) -> String:	
	for k in dict:
		if k == "year":
			continue
		
		if k == "dst":
			continue
		
		if dict[k] < 10:
			dict[k] = str("0") + str(dict[k])
	
	var date = str(dict["year"]) + "-" + str(dict["month"]) + "-" + str(dict["day"]) + " " + str(dict["hour"]) + ":" + str(dict["minute"]) + ":" + str(dict["second"])
	return date

static func str_to_color(str: String) -> Color:
	var new_string = str.erase(0).erase(len(str) - 2)
	var split = new_string.split(",")
	var new_color = Color(float(split[0]), float(split[1]), float(split[2]), float(split[3]))
	return new_color
