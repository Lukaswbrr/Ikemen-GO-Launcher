extends Control

const time = preload("res://scripts/time_stuff.gd")
const format = preload("res://scripts/format_stuff.gd")

var current_time = Time.get_datetime_dict_from_system()
var version_time = {"year": 2026, "month": 10, "day": 12, "hour": 15, "minute": 35, "second": 50}

func _ready() -> void:
	print( time.is_up_to_date(version_time, current_time) )
	
	await get_tree().create_timer(3).timeout
	check_up_to_date()

func check_up_to_date():
	if ( time.is_up_to_date(version_time, current_time) ):
		show_update_panel("noupdate")
		$NoUpdate/Label.set_text($NoUpdate/Label.text % format.format_date_dict(current_time))
	else:
		show_update_panel("available")
		$UpdateAvailable/Label.set_text($UpdateAvailable/Label.text % [format.format_date_dict(current_time), format.format_date_dict(version_time)] )

func hide_update_panel() -> void:
	if visible:
		set_visible(false)

func set_visible_all(visibility: bool, except: Array):
	for k in get_children():
		if k in except:
			continue
		
		k.set_visible(visibility)

func show_update_panel(status: String) -> void:
	if not visible:
		set_visible(true)
	
	match status:
		"checking":
			set_visible_all(false, [$Panel, $CheckingUpdate])
			$CheckingUpdate.set_visible(true)
			
		"available":
			set_visible_all(false, [$Panel, $UpdateAvailable])
			$UpdateAvailable.set_visible(true)
		"noupdate":
			set_visible_all(false, [$Panel, $NoUpdate])
			$NoUpdate.set_visible(true)
		"downloading":
			set_visible_all(false, [$Panel, $Downloading])
			$Downloading.set_visible(true)
		"failed":
			set_visible_all(false, [$Panel, $Failed])
			$Failed.set_visible(true)
		"success":
			set_visible_all(false, [$Panel, $Success])
			$Success.set_visible(true)
	pass

func _on_close_pressed():
	set_visible(false)
