@tool
extends EditorScript

var update_available: bool
var current_time = Time.get_datetime_dict_from_system()
var version_time = {"year": 2024, "month": 10, "day": 12, "hour": 15, "minute": 35, "second": 50}

# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	current_time.erase("weekday")
	current_time.erase("dst")
	
	check_time_difference(version_time, current_time)
	
	print(current_time)

func check_time_difference(time_to: Dictionary, time_from: Dictionary):
	var difference = {
		year = time_to["year"] - time_from["year"],
		month = time_to["month"] - time_from["month"],
		day = time_to["day"] - time_from["day"],
		hour = time_to["hour"] - time_from["hour"],
		minute = time_to["minute"] - time_from["minute"],
		second = time_to["second"] - time_from["second"]
	}
	
	print(difference)
	
	for k in difference:
		if difference[k] <= 0:
			if k == "hour" or k == "minute":
				
				if difference[k] == 0:
					continue
				
				print(k + " is already above, breaking for and being up to date!")
				break
				
			print(k + " is up to date!")
			continue
		
		print("Your version is outdated by %s years, %s months, %s days, %s hours, %s minutes, %s seconds" % [difference["year"], difference["month"], difference["day"], difference["hour"], difference["minute"], difference["second"]])
		#print("Update available!")
		update_available = true
		break
	
func update():
	if not update_available:
		print("No update available!")
		return
	
	current_time = version_time
	update_available = false
	print("Updated!")
