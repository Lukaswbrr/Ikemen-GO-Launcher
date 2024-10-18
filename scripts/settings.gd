extends Window

signal reset_folders
signal save_folders

@onready var auto_load_folders: CheckBox = $TabContainer/General/Scroll/AutoLoadFolders/CheckBox
@onready var auto_unzip: CheckBox = $TabContainer/General/Scroll/AutoUnzip/CheckBox



func _on_json_location_pressed() -> void:
	OS.shell_open(OS.get_user_data_dir())


func _on_save_folders_pressed() -> void:
	emit_signal("save_folders")


func _on_reset_folders_pressed() -> void:
	emit_signal("reset_folders")
