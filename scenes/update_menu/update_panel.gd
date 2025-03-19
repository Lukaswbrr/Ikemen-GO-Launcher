extends Control

const time = preload("res://scripts/time_stuff.gd")
const format = preload("res://scripts/format_stuff.gd")
const web = preload("res://scripts/https_requests.gd")

var current_time = Time.get_datetime_dict_from_system()
var version_time = {"year": 2026, "month": 10, "day": 12, "hour": 15, "minute": 35, "second": 50}
var active_panel: Control
var active_ikemen_go

# Current implementation idea for auto-update
# 0.5 - Check if ikemen go is up to date with latest nightly version [V]
# 1 - Download ikemen go to a zip file inside the ikemen go game
# 2 - Move desired files to TEMP
# 3 - Delete folders and files that ins't TEMP
# 4 - Extract content from zip to ikemen go folder game [ignores should autoUnzip option]
# 5 - Remove ikemen go zip (ignores the auto remove zip option)
# 6 - Move files from TEMP to new ikemen go folder
# 6.1 - Maybe a option to overwrite files or delete files?
# 7 - Remove TEMP
# 8 - Done

func _ready() -> void:
	pass

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
			active_panel = $CheckingUpdate
			set_visible_all(false, [$Panel, $CheckingUpdate])
			$CheckingUpdate.set_visible(true)
		"available":
			active_panel = $UpdateAvailable
			set_visible_all(false, [$Panel, $UpdateAvailable])
			$UpdateAvailable.set_visible(true)
		"noupdate":
			active_panel = $NoUpdate
			set_visible_all(false, [$Panel, $NoUpdate])
			$NoUpdate.set_visible(true)
		"downloading":
			active_panel = $Downloading
			set_visible_all(false, [$Panel, $Downloading])
			$Downloading.set_visible(true)
		"failed":
			active_panel = $Failed
			set_visible_all(false, [$Panel, $Failed])
			$Failed.set_visible(true)
		"success":
			active_panel = $Success
			set_visible_all(false, [$Panel, $Success])
			$Success.set_visible(true)
		"notnightly":
			active_panel = $NotNightly
			set_visible_all(false, [$Panel, $NotNightly])
			$NotNightly.set_visible(true)

func update_text(strings: Array) -> void:
	var label = active_panel.get_node("Label")
	print("The label!!!!!!" + str(label))
	print(label.text.format(strings))
	label.set_text(label.text.format(strings))

func _on_close_pressed():	
	active_ikemen_go = null
	set_visible(false)
