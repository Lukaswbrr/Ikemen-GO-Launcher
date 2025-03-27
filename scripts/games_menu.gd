extends Control

@export var debug_create: bool ## When enabled, does not create any location files.
@export var list_ignore: Array

@onready var game_container = $List/ScrollContainer/FlowContainer
@onready var add_ikemen_button = $List/ScrollContainer/FlowContainer/AddIkemen

@onready var game_panel = $GamePanel
@onready var new_ikemen_window: Window = $CreateNewIkemen

# settings variables
@export var save_file_name: String
@export var auto_load_settings: bool
@onready var settings = $Settings/SettingsWindow

@onready var download_panel: Control = $DownloadPanel
@onready var download_http: HTTPRequest = $HTTPRequest/Download
@onready var update_http: HTTPRequest = $HTTPRequest/Update
@onready var web: HTTPRequest = $HTTPRequest

@onready var no_config_panel: Control = $NoConfigPanel

# preload scripts
const time = preload("res://scripts/time_stuff.gd")
const format = preload("res://scripts/format_stuff.gd")
const json_handler = preload("res://scripts/json_handler.gd")
const file = preload("res://scripts/file_stuff.gd")

var id = 1

# Variables for ConfirmDialog
var confirm_location: String
var confirm_os: String
var confirm_version: String

# Variables for Update HTTP
var current_updating_ikemen

# Internal variables for load ikemen folder operation
var _loaded_folders: Array
var _no_config_dirs: Array
var _create_id: int


## probaly improve this, using the template from json handler? idk
var _create_default_config: Dictionary = {
	ikemen_name = "IKEMEN Go Game " + str(_create_id),
	album_display = "IKEMEN Go Game " + str(_create_id),
	album_color = Color(1, 0, 0, 1),
	background_color = Color(0, 1, 0, 1),
	desc_color = Color(0, 0, 1, 1),
	ikemen_title_color = Color(1, 1, 0, 1),
	album_text_color = Color(0, 1, 1, 1),
	auto_update = false,
	should_album_display_text = true,
	desc = "Ikemen GO created with default configuration",
	executable_file = "",
	tags = "",
	location = "",
	version = "v0.99.0",
	operating_system = OS.get_name(),
	"date_created" = Time.get_datetime_string_from_system(false, true),
	"date_version" = "",
	commit = "",
	music_auto_play = "",
	music_file = "",
	author_name = "",
	ignore_update_folder = "",
	ignore_update_file = "",
}


func _ready() -> void:
	if debug_create:
		$Debug.set_visible(true)
		print("debug enabled")
	
	json_handler.create_save("launcher_config.json", json_handler.launcher_configuration_default)
	
	if auto_load_settings:
		load_settings()

func show_download_panel(status: String) -> void:
	if not download_panel.visible:
		download_panel.set_visible(true)
	
	match status:
		"downloading":
			download_panel.get_node("Failed").set_visible(false)
			download_panel.get_node("Success").set_visible(false)
			
			download_panel.get_node("Downloading").set_visible(true)
		"failed":
			download_panel.get_node("Downloading").set_visible(false)
			download_panel.get_node("Success").set_visible(false)
			
			download_panel.get_node("Failed").set_visible(true)
		"success":
			download_panel.get_node("Downloading").set_visible(false)
			download_panel.get_node("Failed").set_visible(false)
			
			download_panel.get_node("Success").set_visible(true)

func close_download_panel() -> void:
	download_panel.set_visible(false)

func _process(_delta: float) -> void:
	if download_http.get_body_size() != 1:
		var size = download_http.get_body_size()
		var current = download_http.get_downloaded_bytes()
		$DownloadPanel/Downloading/ProgressBar.value = current*100/size
	
	if update_http.get_body_size() != 1 and !current_updating_ikemen == null:
		var size = update_http.get_body_size()
		var current = update_http.get_downloaded_bytes()
		var progress = current_updating_ikemen.get_meta("gamePanel").get_node("UpdatePanel/Downloading/ProgressBar")
		progress.value = current*100/size

func clear_confirm() -> void:
	confirm_location = ""
	confirm_os = ""
	confirm_version = ""

func check_ikemen_files_status(location: String, should_popup_if_success: bool = false) -> bool:
	var dir = DirAccess.open(location)
	
	if dir == null:
		print("Invalid location!")
		return false
	
	dir.include_hidden = true
	
	var dirs_hidden = dir.get_directories()
	var dirs = DirAccess.get_directories_at(location)
	var files = DirAccess.get_files_at(location)
	
	if ".godot_launcher" in dirs_hidden:
		print("configuration found")
	
	if dirs.is_empty():
		print("there are no directories!")
		return false
	
	return true

func download(os: String, location: String, version: String, type: String = "new"):
	var download_path = location + "/Ikemen_GO_" + os + "_" + version + ".zip"
	match type:
		"new":
			web.download_ikemen_go(download_path, os, version)
		"update":
			web.download_ikemen_go(download_path, os, version, "update")

func create_ikemen_item(ikemen: Dictionary, create_config: bool = true) -> void:
	var scene = preload("res://scenes/game_item.tscn")
	var button: Button = scene.instantiate()
	var game_id = id
	var new_stylebox = StyleBoxFlat.new()
	
	# convert values case if its string
	for k in ["album_color", "album_text_color", "desc_color", "ikemen_title_color", "background_color"]:
		if typeof(ikemen[k]) == 4:
			ikemen[k] = format.str_to_color(ikemen[k])
	
	# Meta-data for the buttons
	button.set_meta("albumText", ikemen["album_display"])
	button.set_meta("shouldDisplayAlbumText", ikemen["should_album_display_text"])
	button.set_meta("tags", ikemen["tags"])
	
	if ikemen["should_album_display_text"]:
		button.text = ikemen["album_display"]
	
	new_stylebox.bg_color = ikemen["album_color"]
	
	button.add_theme_color_override("font_color", ikemen["album_text_color"])
	button.add_theme_stylebox_override("normal", new_stylebox)
	
	var panel_scene = preload("res://scenes/game_panel_item.tscn")
	var new_game = panel_scene.instantiate()
	var ikemen_title = new_game.get_node("Title")
	var background = new_game.get_node("Background")
	var ikemen_description = new_game.get_node("Description")
	var edit = new_game.get_node("Edit")
	var play = new_game.get_node("Play")
	var list = new_game.get_node("List")
	var list_window = new_game.get_node("List/ListWindow")
	var close = new_game.get_node("Close")
	var open_folder = new_game.get_node("OpenFolder")
	var update = new_game.get_node("Update")
	var update_panel = new_game.get_node("UpdatePanel")
	var update_available_panel = new_game.get_node("UpdatePanel/UpdateAvailable/Label")
	
	new_game.set_meta("location", ikemen["location"])
	new_game.set_meta("exeFile", "Ikemen-GO-Linux") # name of what ikemen go file to execute
	
	new_game.name = ikemen["ikemen_name"]
	ikemen_title.text = ikemen["ikemen_name"]
	ikemen_title.add_theme_color_override("font_color", ikemen["ikemen_title_color"])
	ikemen_description.text = ikemen["desc"]
	ikemen_description.add_theme_color_override("font_color", ikemen["desc_color"])
	background.color = ikemen["background_color"]
	
	# Button meta
	button.set_meta("gamePanel", new_game)
	button.set_meta("dictData", ikemen)
	
	# Creates folders and files
	if ikemen["location"].is_empty():
		print("location empty, not creating folder")
	
	if create_config and not debug_create:
		DirAccess.make_dir_absolute(ikemen["location"] + "/" + ".godot_launcher")
		
		var config_file = FileAccess.open(ikemen["location"] + "/" + ".godot_launcher/config.json", FileAccess.WRITE)
		config_file.store_string(JSON.stringify(ikemen, "\t"))
		config_file.close()
	
	button.pressed.connect(func():
		$List.visible = !$List.visible
		new_game.visible = !new_game.visible
		for k in list_ignore:
			get_node(k).visible = !get_node(k).visible
		
		if not check_ikemen_files_status(button.get_meta("dictData")["location"]):
			confirm_location = button.get_meta("dictData")["location"]
			confirm_os = button.get_meta("dictData")["operating_system"]
			confirm_version = button.get_meta("dictData")["version"]
			$NoFilesDialog.popup_centered()
			print("There is no files!!!")
		)
		
	
	edit.pressed.connect(func():
		new_ikemen_window.edit_ver()
		new_ikemen_window.selected_ikemen_edit = button
		new_ikemen_window.load_values(button.get_meta("dictData"))
		new_ikemen_window.popup_centered()
		)
	
	play.pressed.connect(func():
		match OS.get_name():
			"Windows":
				var error = OS.execute("bash/run_ikemen_go_windows.bat", [button.get_meta("dictData")["location"], button.get_meta("dictData")["executable_file"]])
			"Linux":
				var error = OS.execute("bash", ["bash/run_ikemen_go_linux.sh", "open", button.get_meta("dictData")["location"], button.get_meta("dictData")["executable_file"]])
		#print(error)
		#print(ikemen["location"])
		)
	
	close.pressed.connect(func():
		$List.visible = !$List.visible
		new_game.visible = !new_game.visible
		for k in list_ignore:
			get_node(k).visible = !get_node(k).visible
		)
	
	open_folder.pressed.connect(func():
		OS.shell_show_in_file_manager(button.get_meta("dictData")["location"])
		)
	
	update_panel.update_requested.connect(_on_update_panel_update_requested)
	
	update.pressed.connect(func():
		if !button.get_meta("dictData")["version"] == "nightly":
			update_panel.show_update_panel("notnightly")
			return
		
		var test_time = Time.get_datetime_dict_from_datetime_string(button.get_meta("dictData")["date_version"], false)
		var available = await check_ikemen_go_nightly_update(test_time)
		var nightly_date = web.get_latest_nightly_version_date("Linux")
		var test_time_formatted = format.format_date_dict(test_time)
		
		if !available:
			update_panel.show_update_panel("available")
			update_panel.update_text([test_time_formatted, nightly_date])
			update_panel.active_ikemen_go = button
			
			#print(update_panel.active_ikemen_go.get_meta("dictData")["ikemen_name"])
		else:
			update_panel.show_update_panel("noupdate")
			update_panel.update_text([test_time_formatted])
		)
	
	game_container.add_child(button)
	game_container.move_child(add_ikemen_button, game_container.get_children().size())
	
	game_panel.add_child(new_game)
	new_game.setup_paths(ikemen["location"], ikemen["location"] + "/chars", ikemen["location"] + "/data/select.def")

func check_ikemen_go_nightly_update(ikemen_version: Dictionary) -> bool:
	web.request_data()
	
	await web.request_completed
	var nightly_date = web.get_latest_nightly_version_date("Linux")
	var nightly_dict = Time.get_datetime_dict_from_datetime_string(nightly_date, false)
	
	print("web requested finhsed.")
	
	if !time.is_up_to_date(nightly_dict, ikemen_version):
		print("not up to date.")
		return false
	
	print("up to date.")
	return true

func edit_ikemen_item(item, ikemen: Dictionary):
	var button: Button = item
	var new_stylebox = StyleBoxFlat.new()
	
	# convert values case if its string
	for k in ["album_color", "album_text_color", "desc_color", "ikemen_title_color", "background_color"]:
		if typeof(ikemen[k]) == 4:
			ikemen[k] = format.str_to_color(ikemen[k])
	
	# Meta-data for the buttons
	button.set_meta("albumText", ikemen["album_display"])
	button.set_meta("shouldDisplayAlbumText", ikemen["should_album_display_text"])
	button.set_meta("tags", ikemen["tags"])
	
	button.set_meta("dictData", ikemen)
	
	if ikemen["should_album_display_text"]:
		button.text = ikemen["album_display"]
	
	new_stylebox.bg_color = ikemen["album_color"]
	button.add_theme_color_override("font_color", ikemen["album_text_color"])
	button.add_theme_stylebox_override("normal", new_stylebox)
	
	var new_game = button.get_meta("gamePanel")
	var ikemen_title = new_game.get_node("Title")
	var background = new_game.get_node("Background")
	var ikemen_description = new_game.get_node("Description")
	var edit = new_game.get_node("Edit")
	var play = new_game.get_node("Play")
	var list = new_game.get_node("List")
	var close = new_game.get_node("Close")
	
	new_game.set_meta("location", ikemen["location"])
	new_game.set_meta("exeFile", "Ikemen-GO-Linux") # name of what ikemen go file to execute
	
	new_game.name = ikemen["ikemen_name"]
	ikemen_title.text = ikemen["ikemen_name"]
	ikemen_title.add_theme_color_override("font_color", ikemen["ikemen_title_color"])
	ikemen_description.text = ikemen["desc"]
	ikemen_description.add_theme_color_override("font_color", ikemen["desc_color"])
	background.color = ikemen["background_color"]
	
	# Creates folders and files
	
	if not debug_create:
		var config_file = FileAccess.open(ikemen["location"] + "/" + ".godot_launcher/config.json", FileAccess.READ_WRITE)
		var config_data = config_file.get_as_text()
		var json = JSON.new()
		
		var error = json.parse(config_data)
		if error == OK:
			ikemen.merge(json.data, false)
			print("File already exists, merging new edit keys to existant config")
			config_file.store_string(JSON.stringify(ikemen, "\t"))
		else:
			print("File doesn't exist???? making new one")
			config_file.store_string(JSON.stringify(ikemen, "\t"))
			
		config_file.close()

func load_ikemen_folders(dir: String) -> void:
	var directories = DirAccess.get_directories_at(dir)
	
	#print(directories)
	
	for k in directories:
		var sub_dir_access = DirAccess.open(dir + "/" + k)
		sub_dir_access.set_include_hidden(true)
		var sub_dir = sub_dir_access.get_directories()
		
		#print(sub_dir)
		
		if ".godot_launcher" in sub_dir:
			var config = FileAccess.open(dir + "/" + k + "/.godot_launcher/config.json", FileAccess.READ )
			var dict = JSON.parse_string(config.get_as_text())
			#print(dict)
			
			create_ikemen_item(dict, false)
		else:
			_no_config_dirs.append(dir + "/" + k)
	
	if _no_config_dirs.size() > 0:
		print("there are dirs with no configuration!")
		print(_no_config_dirs)
		_start_no_config_operation()
	
	if directories.size() > 0:
		_loaded_folders.append(dir)

func _on_button_pressed() -> void:
	new_ikemen_window.create_ver()
	new_ikemen_window.popup_centered()


func _on_create_new_ikemen_close_requested() -> void:
	new_ikemen_window.hide()


func _on_create_new_ikemen_new_ikemen_created(project: Dictionary) -> void:
	var version_date = web.get_requested_data_assets_os_version(project["version"], project["operating_system"])["updated_at"]
	var version_dict = Time.get_datetime_dict_from_datetime_string(version_date, false)
	
	project["date_version"] = Time.get_datetime_string_from_datetime_dict(version_dict, true)
	
	create_ikemen_item(project)
	$ConfirmDialog.popup_centered()
	id += 1
	
	confirm_location = project["location"]
	confirm_os = project["operating_system"]
	confirm_version = project["version"]
	$ConfirmDialog.popup_centered()


func _on_edit_ikemen_new_ikemen_created(project: Dictionary) -> void:
	print("edit ikemen has been pressed!")


func _on_load_folder_pressed() -> void:
	$LoadFolder/FileDialog.popup()

# for load ikemen folders when there are multiple no config folders
func _start_no_config_operation() -> void:
	if _no_config_dirs.size() <= 0:
		print("_no_config is empty, returning")
		return
	
	no_config_panel.set_visible(true)
	no_config_panel.select_folder(_no_config_dirs[0])


func _cancel_no_config_operation() -> void:
	_no_config_dirs.clear()
	no_config_panel.set_visible(false)
	no_config_panel.select_folder("")

func _create_default_ikemen_config(location: String) -> void:
	pass

func _on_load_ikemen_folders_dir_selected(dir: String) -> void:
	load_ikemen_folders(dir)


func _on_edit_ikemen_pressed(old_ikemen: Variant, project: Dictionary) -> void:
	#print("Old ikemen is: " + str(old_ikemen))
	#print(project)
	edit_ikemen_item(old_ikemen, project)


func _on_create_new_ikemen_fetch_request() -> void:
	web.request_data()
	await web.request_completed
	
	var id_for: int
	var version_list: Array
	
	for k in web.requested_data:
		version_list.append(web.requested_data[id_for]["name"])
		
		id_for += 1
	
	new_ikemen_window.update_versions(version_list)
	print("New version: " + web.get_latest_nightly_version_date("Windows"))


func _on_confirm_dialog_confirmed() -> void:
	if confirm_location == "" or confirm_os == "" or confirm_version == "":
		printerr("Download failed due to one of confirm variables being empty!")
		print("Confirm location: " + confirm_location)
		print("Confirm os: " + confirm_os)
		print("Confirm version:" + confirm_version)
		return
	
	print("Confirmed download")
	
	show_download_panel("downloading")
	download(confirm_os, confirm_location, confirm_version)


func _on_confirm_dialog_canceled() -> void:
	print("Cancelled download")
	clear_confirm()

func unzip_ikemen(download_file: String, extract_path: String) -> void:
	match OS.get_name():
		"Windows":
			var error = OS.execute("tar", ["-xf", download_file, "-C", extract_path])
		"Linux":
			var error = OS.execute("unzip", [download_file, "-d", extract_path])

func _on_download_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("response_code " + str(response_code) )
	print("request finished.")
	
	match response_code:
		200: # success
			download_http.started = false
			
			var split: PackedStringArray = download_http.download_file.split("/")
			var file_name = split[split.size() - 1]
			split.remove_at(split.size() - 1)
			var joined = "/".join(split)
			
			show_download_panel("success")
			clear_confirm()
			print("it printed!!")
			
			# check settings
			if settings.auto_unzip.button_pressed:
				unzip_ikemen(download_http.download_file, joined)
				DirAccess.remove_absolute(download_http.download_file)

func _on_update_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("response_code " + str(response_code) )
	print("request finished.")
	
	match response_code:
		200: # success
			update_http.started = false
			
			var split: PackedStringArray = update_http.download_file.split("/")
			var file_name = split[split.size() - 1]
			split.remove_at(split.size() - 1)
			var joined = "/".join(split)
			
			print("The joined thing..." + joined)
			
			# check settings
			#unzip_ikemen(download_http.download_file, joined)
			current_updating_ikemen.get_meta("gamePanel").get_node("UpdatePanel").show_update_panel("success")
			
			var ikemen_dict = current_updating_ikemen.get_meta("dictData")
			var ikemen_file_name = "Ikemen_GO_" + ikemen_dict["operating_system"] + "_" + ikemen_dict["version"] + ".zip"
			var config_file = FileAccess.open(ikemen_dict["location"] + "/" + ".godot_launcher/config.json", FileAccess.WRITE)
			ikemen_dict["date_version"] = web.get_latest_nightly_version_date("Linux")
			config_file.store_string(JSON.stringify(ikemen_dict, "\t"))
			config_file.close()
			
			file.temp_create(ikemen_dict["location"])
			file.copy_paste_only(ikemen_dict["location"], ["chars"], ["data/select.def"], ikemen_dict["location"] + "/TEMP")
			file.delete_ikemen_files(ikemen_dict["location"], [ikemen_file_name])
			unzip_ikemen(ikemen_dict["location"] + "/" + ikemen_file_name, ikemen_dict["location"])
			OS.move_to_trash(ikemen_dict["location"] + "/" + ikemen_file_name)
			file.copy_paste_only(ikemen_dict["location"] + "/TEMP", ikemen_dict["ignore_update_folder"].split(","), ikemen_dict["ignore_update_file"].split(","), ikemen_dict["location"])
			OS.move_to_trash(ikemen_dict["location"] + "/TEMP")
			
			current_updating_ikemen = null

func _on_about_pressed() -> void:
	$AboutWindow.popup_centered()


func _on_about_window_close_requested() -> void:
	$AboutWindow.hide()

func _on_no_config_panel_skip_operation() -> void:
	_no_config_dirs.pop_front()
	_start_no_config_operation()



func _on_no_config_panel_create_default_operation() -> void:
	var new_location = _no_config_dirs[0]
	var new_game = _create_default_config.duplicate()
	
	new_game["location"] = new_location
	
	_create_id += 1
	new_game["ikemen_name"] = "IKEMEN Go Game " + str(_create_id)
	new_game["album_display"] = new_game["ikemen_name"]
	
	match OS.get_name():
		"Windows":
			new_game["executable_file"] = "Ikemen_GO.exe"
		"Linux":
			new_game["executable_file"] = "Ikemen_GO_Linux"
	
	_no_config_dirs.pop_front()
	
	create_ikemen_item(new_game)
	_start_no_config_operation()

func save_settings() -> void:
	var save_dict = json_handler.launcher_configuration_default.duplicate()
	save_dict["autoLoadFolders"] = settings.auto_load_folders.button_pressed
	save_dict["autoUnzip"] = settings.auto_unzip.button_pressed
	save_dict["keepIKEMENZipDownload"] = settings.keep_ikemen_zip_download.button_pressed
	save_dict["loadFolders"] = _loaded_folders
	
	json_handler.update_save(save_file_name, save_dict)

func load_settings() -> void:
	var dict = json_handler.load_autosave(save_file_name)
	
	for k in dict:
		match k:
			"autoLoadFolders":
				settings.auto_load_folders.button_pressed = dict[k]
			"autoUnzip":
				settings.auto_unzip.button_pressed = dict[k]
			"loadFolders":
				_loaded_folders = dict[k]
				if dict[k].size() > 0:
					load_ikemen_folders(dict[k][0])
				else:
					print("It's empty the load folders argument!")
			_:
				print(k)

func _on_settings_pressed() -> void:
	$Settings/SettingsWindow.popup_centered()


func _on_settings_window_save_folders() -> void:
	save_settings()


func _on_settings_window_reset_folders() -> void:
	var dict = json_handler.load_autosave(save_file_name)
	
	dict["loadFolders"] = []
	
	json_handler.update_save(save_file_name, dict)

func _on_update_panel_update_requested(ikemen: Button) -> void:
	current_updating_ikemen = ikemen
	
	download(current_updating_ikemen.get_meta("dictData")["operating_system"], current_updating_ikemen.get_meta("dictData")["location"], current_updating_ikemen.get_meta("dictData")["version"], "update")
