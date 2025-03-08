@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	print( format_date_array("2024-08-12T09:57:49Z") )

func format_date_array(date: String) -> Array:
	var split = date.split("T")
	var time = [split[0], split[1].replace("Z", "")]
	
	print(time[0] + " " + time[1])
	return time
