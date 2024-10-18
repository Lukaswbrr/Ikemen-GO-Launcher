extends Control

var current_os: String = OS.get_name()
var current_time = "2024-07-29"
var download_file_path: String
var play_file_path: String
var up_to_date: bool

@onready var selected_download_label: Label = $SelectedDownload
@onready var selected_download_original_text: String = selected_download_label.get_text()
@onready var progress_download: ProgressBar = $DownloadProgress/ProgressBar
@onready var progress_download_label: Label = $DownloadProgress/Label
@onready var download_http: HTTPRequest = $HTTPRequest/Download
@onready var play_label: Label = $SelectedPlay
@onready var play_original_text: String = play_label.get_text()
@onready var os_download: Label = $"OS Download"
@onready var requested_data_label: Label = $RequestedData
@onready var requested_data_original_text: String = requested_data_label.get_text()
@onready var button_window: Window = $About/AboutWindow
@onready var button_window_main_pos: Vector2

@onready var archive: Window = $Archive/ArchiveMenu
@onready var settings: Window = $Settings/SettingsWindow
@onready var web = $HTTPRequest

@onready var format_script: GDScript = preload("res://scripts/format_stuff.gd")
@onready var json_handler: GDScript = preload("res://scripts/json_handler.gd")

var save_file_name: String = "old_launcher_config.json"

func _ready() -> void:
	os_download.set_text(os_download.get_text() % current_os)
	json_handler.create_save(save_file_name, json_handler.launcher_configuration_default)
	print( json_handler.load_autosave(save_file_name) )
	auto_load()

func load_settings() -> void:
	print(json_handler.load_autosave(save_file_name))

func save_settings() -> void:
	var save_dict = json_handler.launcher_configuration_default
	save_dict["autoLoadFolders"] = settings.auto_load_folders.button_pressed
	save_dict["archiveAutoLoad"] = archive.auto_load_folder.button_pressed
	save_dict["autoUnzip"] = settings.auto_unzip.button_pressed
	save_dict["playFolder"] = play_file_path
	save_dict["archiveFolder"] = archive.archive_folder
	
	json_handler.update_save(save_file_name, save_dict)

func auto_load() -> void:
	var dict = json_handler.load_autosave(save_file_name)
	
	var new_play_file_path: String
	
	for k in dict:
		match k:
			"autoLoadFolders":
				settings.auto_load_folders.button_pressed = dict[k]
				print("arghhh")
			"autoUnzip":
				settings.auto_unzip.button_pressed = dict[k]
			"playFolder":
				new_play_file_path = dict[k]
				play_label.set_text(play_label.text % dict[k])
			_:
				print(k)
	
	if settings.auto_load_folders.button_pressed:
		play_file_path = new_play_file_path
		archive.selected_ikemen_go_folder = new_play_file_path

func is_up_to_date() -> bool:
	var data = web.get_requested_data_nightly(current_os)
	var split = data["updated_at"].split("T")
	
	var time = [split[0], split[1].replace("Z", "")]
	var ymd_split = time[0].split("-")
	var hours_split = time[1].split(":")
	
	var current_time_split = current_time.split("-")
	
	# this code currently sucks, is there a better way to do this?
	
	var data_time_dict = {
		year = int(ymd_split[0]),
		month = int(ymd_split[1]),
		day = int(ymd_split[2]),
		hours = int(hours_split[0]),
		minutes = int(hours_split[1]),
		seconds = int(hours_split[2])
	}
	
	var current_time_dict = {
		year = int(current_time_split[0]),
		month = int(current_time_split[1]),
		day = int(current_time_split[2])
	}
	
	
	if data_time_dict["day"] > current_time_dict["day"]:
		print("Outdated!")
	else:
		print("Up to date!")
	
	print(current_time_dict["day"])
	
	return true


func _process(_delta: float) -> void:
	if download_http.get_body_size() != 1:
		var size = download_http.get_body_size()
		var current = download_http.get_downloaded_bytes()
		$DownloadProgress/ProgressBar.value = current*100/size


func _on_about_pressed() -> void:
	button_window.popup()
	button_window_main_pos = button_window.get_position_with_decorations()
	button_window.move_to_center()


func download() -> void:
	var extract_path = download_file_path + "/"
	var ikemen_go = download_file_path + "./Ikemen_GO_Linux"
	var download = download_file_path + "/Ikemen_GO_" + current_os + ".zip"
	web.download_ikemen_go(download, current_os, "nightly")

func unzip_ikemen() -> void:
	var extract_path = download_file_path + "/"
	var download = download_file_path + "/Ikemen_GO_" + current_os + ".zip"
	match current_os:
		"Windows":
			var error = OS.execute("tar", ["-xf", download, "-C", extract_path])
		"Linux":
			var error = OS.execute("unzip", [download, "-d", extract_path])
	

func _on_file_dialog_dir_selected(dir: String) -> void:
	download_file_path = dir
	selected_download_label.set_text(selected_download_original_text)
	selected_download_label.set_text(selected_download_label.text % dir)
	#print(output)
	#print(error)


func _on_set_location_pressed() -> void:
	$SetLocation/FileDialog.popup()

func run_ikemen() -> void:
	match current_os:
		"Linux":
			var output = []
			var error = OS.execute("bash", ["bash/run_ikemen_go_linux.sh", "open", play_file_path, "Ikemen_GO_Linux"], output)
			print(error)
			print(output)
		"Windows":
			#print(play_file_path)
			var output = []
			#var error = OS.execute(play_file_path + "/" + "Ikemen_GO.exe", [], output)
			var error = OS.execute("bash/run_ikemen_go_windows.bat", [play_file_path, "Ikemen_GO.exe"], output)
			print(output)
			

func _on_play_pressed() -> void:
	if !play_file_path:
		print_rich("No play file path selected!")
		return
	
	$Play.disabled = true
	var original_text = $Play.text
	$Play.set_text("Running")
	await get_tree().create_timer(1).timeout
	run_ikemen()
	
	$Play.set_text(original_text)
	$Play.disabled = false


func _on_set_play_location__pressed() -> void:
	$SetPlayLocation/PlayDialog.popup()

func _on_play_dialog_dir_selected(dir: String) -> void:
	play_file_path = dir
	archive.selected_ikemen_go_folder = dir
	play_label.set_text(play_original_text)
	play_label.set_text(play_label.text % play_file_path)


func _on_fetch_pressed() -> void:
	web.request_data()
	await web.request_completed
	var web_updated_at = web.get_requested_data_nightly(current_os)["updated_at"]
	var web_full_date = Time.get_datetime_dict_from_datetime_string(web_updated_at, false)
	
	requested_data_label.set_text(requested_data_original_text)
	requested_data_label.set_text(requested_data_label.text % Time.get_datetime_string_from_datetime_dict(web_full_date, true))


func _on_download_pressed() -> void:
	if !download_file_path:
		print_rich("No download file path!")
		return
	
	if download_http.started:
		print_rich("There's a download in progress!")
		return
	
	progress_download_label.set_text("Downloading")
	download()

func _on_settings_pressed() -> void:
	$Settings/SettingsWindow.popup_centered()

func _on_settings_window_close_requested() -> void:
	$Settings/SettingsWindow.hide()


func _on_download_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	download_http.finished = true
	print("response_code " + str(response_code) )
	print("request finished.")
	
	match response_code:
		200: # success
			download_http.started = false
			progress_download_label.set_text("Download finished!")
			
			# check settings
			if settings.auto_unzip.button_pressed:
				unzip_ikemen()


func _on_archive_pressed() -> void:
	archive.popup_centered()

func _on_archive_menu_close_requested() -> void:
	archive.hide()


func _on_open_play_folder_pressed() -> void:
	if !play_file_path:
		return
	
	OS.shell_open(play_file_path)


func _on_about_window_close_requested() -> void:
	button_window.hide()


func _on_settings_window_save_folders() -> void:
	save_settings()


func _on_settings_window_reset_folders() -> void:
	var file = FileAccess.open("user://" + save_file_name, FileAccess.READ)
	var reset_dict = JSON.parse_string(file.get_as_text())
	reset_dict["playFolder"] = ""
	
	json_handler.update_save(save_file_name, reset_dict)
	
	play_label.set_text(play_original_text % "")
