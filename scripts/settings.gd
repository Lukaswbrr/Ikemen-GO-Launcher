extends Window

signal reset_folders
signal save_settings

@onready var auto_load_folder: CheckBox = $TabContainer/General/Scroll/AutoLoadFolder/CheckBox
@onready var auto_unzip: CheckBox = $TabContainer/General/Scroll/AutoUnzip/CheckBox
@onready var keep_ikemen_zip_download: CheckBox = $TabContainer/General/Scroll/KeepIKEMENZip/CheckBox
@onready var auto_load_folder_path: LineEdit = $TabContainer/General/Scroll/AutoloadFolderPath/LineEdit
@onready var automatic_set_auto_load: CheckBox = $TabContainer/General/Scroll/AutomaticSetAutoLoad/CheckBox
@onready var update_keep_ikemen_zip_download: CheckBox = $TabContainer/Update/Scroll/KeepIKEMENZip/CheckBox
@onready var update_keep_temp_folder: CheckBox = $TabContainer/Update/Scroll/KeepTEMPFolder/CheckBox

func _on_json_location_pressed() -> void:
	OS.shell_open(OS.get_user_data_dir())


func _on_save_settings_pressed() -> void:
	emit_signal("save_settings")


func _on_reset_folders_pressed() -> void:
	emit_signal("reset_folders")

func _on_close_requested() -> void:
	hide()
