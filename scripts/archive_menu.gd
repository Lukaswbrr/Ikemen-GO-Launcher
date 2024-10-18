extends Window

signal add_character_button_pressed(character: String) ## Signal for when a add button is pressed. Uses character argument for character name.

# json handler load
@onready var json_handler: GDScript = preload("res://scripts/json_handler.gd")

# misc context
@onready var misc_context: PopupMenu = $MiscContext

var selected_ikemen_go_folder: String
var archive_folder: String
@onready var archive_open_folder: FileDialog = $TabContainer/Settings/VBoxContainer/LoadArchive/FileDialog

# settings nodes
@onready var select_start_line: LineEdit = $TabContainer/Settings/VBoxContainer/selectStartLine/LineEdit
@onready var auto_load_folder: CheckBox = $TabContainer/Settings/VBoxContainer/AutoLoadFolder
@onready var select_folder_name_node: LineEdit = $TabContainer/Settings/VBoxContainer/selectFolderName/LineEdit
@onready var chars_folder_name_node: LineEdit = $TabContainer/Settings/VBoxContainer/charsFolderName/LineEdit

var characters: Dictionary
var stages: Dictionary
var screenpacks: Dictionary
var musics: Dictionary
var addons: Dictionary

# archive parameters
var archive_characters_path: String = "characters"
var archive_stages_path: String = "stages"

# select.def parameters
var start_line: int = 196
var chars_path: String = "chars"
var select_folder_name: String = "data"

# save file
var save_file_name: String = "archive_settings.json"

# port scripts
@onready var ikemen_files = preload("res://scripts/file_stuff.gd")

func _ready() -> void:
	select_start_line.text = str(start_line)
	select_folder_name_node.text = str(select_folder_name)
	chars_folder_name_node.text = str(chars_path)
	
	json_handler.create_save(save_file_name, json_handler.archive_configuration_default)
	auto_load()

func popup_archive(ikemen_folder: String, chars_folder: String = chars_path, select_location: String = select_folder_name, select_character_start_line: int = 196):
	selected_ikemen_go_folder = ikemen_folder
	chars_path = chars_folder
	select_folder_name = select_location
	start_line = select_character_start_line
	popup_centered()

func clear_selected() -> void:
	selected_ikemen_go_folder = ""


func save_settings() -> void:
	var save_dict = json_handler.archive_configuration_default
	save_dict["archiveAutoLoad"] = auto_load_folder.button_pressed
	save_dict["archiveFolder"] = archive_folder
	save_dict["selectStartLine"] = start_line
	
	json_handler.update_save(save_file_name, save_dict)

func clear_all_list() -> void:
	pass

func clear_characters_list() -> void:
	if $TabContainer/Characters/ScrollContainer/Scroll.get_child_count() == 0:
		return
	
	for k in $TabContainer/Characters/ScrollContainer/Scroll.get_children():
		k.queue_free()

func add_character(char: String) -> void: # Adds character to archive list
	var template = preload("res://scenes/character_item.tscn")
	var character = template.instantiate()
	var display_name = character.get_node("Label")
	var add = character.get_node("Add")
	var misc = character.get_node("Misc")
	
	character.set_name(char)
	display_name.set_text(display_name.text % char)
	
	add.pressed.connect(_on_add_pressed.bind(char))
	misc.pressed.connect(_open_misc_context.bind(char))
	
	$TabContainer/Characters/ScrollContainer/Scroll.add_child(character)


func remove_character() -> void:
	pass

func remove_character_ikemen() -> void:
	pass

func add_stage(stage: String) -> void:
	pass

func add_stage_ikemen(stage: String) -> void:
	if !stages.has(stage):
		printerr(stage + " is not in stages dictionary!")
		return

func remove_stage() -> void:
	pass

func remove_stage_ikemen() -> void:
	pass

func add_screenpack() -> void:
	pass
	
func add_screenpack_ikemen() -> void:
	pass

func remove_screenpack() -> void:
	pass

func remove_screenpack_ikemen() -> void:
	pass

func add_music() -> void:
	pass

func add_music_ikemen() -> void:
	pass

func remove_music() -> void:
	pass

func remove_music_ikemen() -> void:
	pass

func load_character_list(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		print("path " + path + " doesnt exist!")
		return
	
	var characters = DirAccess.get_directories_at(path)
	
	for k in characters:
		add_character(k)
	
func load_stage_list() -> void:
	pass

func load_screenpack_list() -> void:
	pass

func load_music_list() -> void:
	pass

func auto_load() -> void:
	var dict = json_handler.load_autosave(save_file_name)
	
	var new_archive_path: String
	var new_select_start_line: int
	
	for k in dict:
		match k:
			"archiveFolder":
				new_archive_path = dict[k]
			"archiveAutoLoad":
				auto_load_folder.button_pressed = dict[k]
			"selectStartLine":
				new_select_start_line = dict[k]
				#print(dict[k])
			_:
				print(k)
				continue
	
	if auto_load_folder.button_pressed:
		archive_folder = new_archive_path
	
	if auto_load_folder.button_pressed:
		if !new_archive_path.is_empty():
			load_character_list(new_archive_path + "/" + archive_characters_path)
	
	# Updates select.def parameters
	start_line = new_select_start_line
	select_start_line.set_text(str(start_line))

func _process(delta: float) -> void:
	pass


func _on_add_pressed(char: String) -> void:
	emit_signal("add_character_button_pressed", char)


func _on_load_archive_pressed() -> void:
	archive_open_folder.popup_centered()


func _on_file_dialog_dir_selected(dir: String) -> void:
	archive_folder = dir
	print("Set archive folder!")
	
	clear_characters_list()
	load_character_list(archive_folder + "/"  + archive_characters_path)


func _on_open_folder_pressed() -> void:
	if not archive_folder:
		printerr("Archive folder has not been set!")
		OS.alert("Archive folder has not been set!", "Archive menu error!")
		return
	
	OS.shell_open(archive_folder)


func _on_save_auto_load_folder_pressed() -> void:
	save_settings()


func _on_line_edit_text_submitted(new_text: String) -> void:
	start_line = int(new_text)


func _open_misc_context(char: String) -> void:
	misc_context.popup(Rect2i(DisplayServer.mouse_get_position().x - 100, DisplayServer.mouse_get_position().y - 75, 0, 0))
	misc_context.selected_char = char


func _on_misc_context_id_pressed(id: int) -> void:
	match id:
		0:
			OS.shell_open(archive_folder + "/" + archive_characters_path + "/" + misc_context.selected_char)


func _on_select_folder_name_text_submitted(new_text: String) -> void:
	select_folder_name = new_text


func _on_chars_folder_name_text_submitted(new_text: String) -> void:
	chars_path = new_text


func _on_json_location_pressed() -> void:
	OS.shell_open(OS.get_user_data_dir())
