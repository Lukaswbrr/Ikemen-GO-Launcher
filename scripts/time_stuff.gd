extends RefCounted

# Functions related to time, used to check if it's a version is up to date


static func check_time_difference(time_to: Dictionary, time_from: Dictionary) -> void:
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
		break

static func is_up_to_date(time_to: Dictionary, time_from: Dictionary) -> bool:
	var difference = {
		year = time_to["year"] - time_from["year"],
		month = time_to["month"] - time_from["month"],
		day = time_to["day"] - time_from["day"],
		hour = time_to["hour"] - time_from["hour"],
		minute = time_to["minute"] - time_from["minute"],
		second = time_to["second"] - time_from["second"]
	}
	
	
	for k in difference:
		if k == "year" and difference[k] < 0:
			print(k + " is below, breaking for and being up to date!")
			return true
		
		if difference[k] <= 0:
			if k == "hour" or k == "minute":
				
				if difference[k] == 0:
					continue
				
				print(k + " is already above, breaking for and being up to date!")
				return true
			
			print(k + " is up to date!")
			continue
		
		print("Your version is outdated by %s years, %s months, %s days, %s hours, %s minutes, %s seconds" % [difference["year"], difference["month"], difference["day"], difference["hour"], difference["minute"], difference["second"]])
		return false
	
	return true
