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

var characters: Dictionary
var stages: Dictionary
var screenpacks: Dictionary
var musics: Dictionary
var addons: Dictionary

# archive parameters
var archive_characters_path: String = "/characters"
var archive_stages_path: String = "/stages"

# select.def parameters
var start_line: int = 196
var chars_path: String = "/chars"
var select_def_path: String = "/data/select.def"

# save file
var save_file_name: String = "archive_settings.json"

func _ready() -> void:
	select_start_line.text = str(start_line)
	json_handler.create_save(save_file_name, json_handler.archive_configuration_default)
	auto_load()

func save_settings() -> void:
	var save_dict = json_handler.archive_configuration_default
	save_dict["archiveAutoLoad"] = auto_load_folder.button_pressed
	save_dict["archiveFolder"] = archive_folder
	save_dict["selectStartLine"] = start_line
	
	json_handler.update_save(save_file_name, save_dict)

func add_new_line(text: String, line: int, ref: String) -> String:
	var ref_split = ref.split("\n")
	ref_split.insert(max(line - 1, 0), text)
	var final: String
	
	final = "\n".join(ref_split)
	
	return final


func clear_all_list() -> void:
	pass

func clear_characters_list() -> void:
	for k in $TabContainer/Characters/Scroll.get_children():
		k.queue_free()
 
func copy_test(path_from: String, path_to: String) -> void:
	if path_from == path_to:
		printerr("Path from is same as path to!")
		return
	
	if DirAccess.dir_exists_absolute(path_to):
		printerr("Path to folder already exists!")
		return
	
	var dir = DirAccess.open(path_from)
	if !dir:
		print("An error occurred when trying to access the path.")
		return
	dir.set_include_hidden(false)
	
	dir.make_dir_recursive(path_to)
	
	var files: int
	var directories: int
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "" and file_name != "..":
		if dir.current_is_dir():
			directories += 1
			print("\n")
			print("Found directory: " + path_from + "/" + file_name)
			copy_test(path_from + "/" + file_name, path_to + "/" + file_name)
		else:
			files += 1
			print("Found file: " + path_from + "/" + file_name)
			DirAccess.copy_absolute(path_from + "/" + file_name, path_to + "/" + file_name) 
		file_name = dir.get_next()
	
	print("\n")
	print("Path from: " + path_from + " will copy to: " + path_to)
	print("Files found: " + str(files))
	print("Directories found: " + str(directories))

func get_char_list(start: int, ref: String) -> Array:
	var ref_split = ref.split("\n")
	var array: Array
	var id = start
	var characters_ids: Array
	
	for k in ref_split:
		if ref_split[id - 1].is_empty(): # end for statement if line is empty
			break
		
		array.append(ref_split[id - 1])
		characters_ids.append(id)
		id += 1
	
	return array

func get_char_list_absolute(start: int, ref: String) -> Array:
	var array: Array = get_char_list(start, ref)
	var characters: Array
	
	for k in array:
		characters.append(k.split(",")[0])
	
	# ID references:
	# 0 = character
	# 1 = character's stage
	# 2 = order
	
	
	return characters

func get_char_list_id(start: int, ref: String) -> Array:
	var ref_split = ref.split("\n")
	var id = start
	var characters_ids: Array
	
	for k in ref_split:
		if ref_split[id - 1].is_empty(): # end for statement if line is empty
			break
		
		characters_ids.append(id)
		id += 1
	
	return characters_ids

func add_character_def(char: String, slot: int, path: String) -> void: # Adds character to select.def file
	if slot < 1:
		print("invalid slot!")
		return
	
	var select_ikemen = FileAccess.open(path, FileAccess.READ)
	if select_ikemen == null:
		print("invalid path!!")
		return
	
	var ref = select_ikemen.get_as_text()
	
	var characters = get_char_list_absolute(start_line, ref)
	var char_ids = get_char_list_id(start_line, ref)
	var end_line: int = char_ids[max(char_ids.size() - 1, 0)] if char_ids.size() > 0 else 0
	
	var first_slot: int = 1
	var last_slot: int = char_ids.size()
	
	if char in characters:
		print("character already in def!")
		return
	
	if last_slot <= 0:
		print("theres no slots!")
		print("since theres no slots, " + char + " will be added in start line " + str(start_line))
		select_ikemen = FileAccess.open(path, FileAccess.WRITE)
		select_ikemen.store_string(add_new_line(char, start_line, ref))
		select_ikemen.close()
		return
	
	
	if slot == last_slot + 1:
		print("expection!")
		print("slot " + str(slot) + " will add " + char + " in front of array id " + str(end_line) + " (will be line " + str(end_line + 1) + ")")
		select_ikemen = FileAccess.open(path, FileAccess.WRITE)
		select_ikemen.store_string(add_new_line(char, end_line + 1, ref))
		select_ikemen.close()
		return
	elif slot > last_slot + 1:
		print("slot " + str(slot) + " is above max slot!")
		return
	
	select_ikemen = FileAccess.open(path, FileAccess.WRITE)
	select_ikemen.store_string(add_new_line(char, char_ids[slot - 1], ref))
	select_ikemen.close()

func add_character(char: String) -> void: # Adds character to archive list
	var template = preload("res://scenes/old_character_item.tscn")
	var character = template.instantiate()
	var display_name = character.get_node("Label")
	var add = character.get_node("Add")
	var add_def = character.get_node("AddDef")
	var remove = character.get_node("Remove")
	var remove_def = character.get_node("RemoveDef")
	var misc = character.get_node("Misc")
	
	character.set_name(char)
	display_name.set_text(display_name.text % char)
	
	add.pressed.connect(_on_add_pressed.bind(char))
	add_def.pressed.connect(_on_add_def_pressed.bind(char))
	remove.pressed.connect(_on_remove_pressed.bind(char))
	remove_def.pressed.connect(_on_remove_def_pressed.bind(char))
	misc.pressed.connect(_open_misc_context.bind(char))
	
	
	
	$TabContainer/Characters/ScrollContainer/Scroll.add_child(character)

func remove_line(line: int, ref: String) -> String:
	var ref_split = ref.split("\n")
	ref_split.remove_at(max(line - 1, 0))
	var final: String
	
	final = "\n".join(ref_split)
	
	return final


func remove_character_def(char: String, path: String) -> void:
	var select_ikemen = FileAccess.open(path, FileAccess.READ)
	if select_ikemen == null:
		print("invalid path!!")
		return
	
	var ref = select_ikemen.get_as_text()
	
	var start_line = 196
	var char_ids = get_char_list_id(start_line, ref)
	var characters = get_char_list_absolute(start_line, ref)
	var end_line: int = char_ids[max(char_ids.size() - 1, 0)] if char_ids.size() > 0 else 0
	
	if char_ids.size() < 1:
		print("theres no characters!")
		return
	
	if not char in characters:
		print("character is not in def!")
		return
	
	var remove_id = characters.find(char)
	var remove_id_line = char_ids[remove_id]
	char_ids.remove_at(remove_id)
	characters.remove_at(remove_id)
	
	print(char_ids)
	print(characters)
	
	select_ikemen = FileAccess.open(path, FileAccess.WRITE)
	select_ikemen.store_string(remove_line(remove_id_line, ref))
	select_ikemen.close()

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
		print("path doesnt exist!")
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
				print(dict[k])
			_:
				print(k)
				continue
	
	if auto_load_folder.button_pressed:
		archive_folder = new_archive_path
	
	if auto_load_folder.button_pressed:
		if !new_archive_path.is_empty():
			load_character_list(new_archive_path + archive_characters_path)
	
	# Updates select.def parameters
	start_line = new_select_start_line
	select_start_line.set_text(str(start_line))

func _process(delta: float) -> void:
	pass


func _on_add_pressed(char: String) -> void:
	add_character_def(char, 1, selected_ikemen_go_folder + select_def_path)
	copy_test(archive_folder + archive_characters_path + "/" + char , selected_ikemen_go_folder + chars_path + "/" + char)


func _on_add_def_pressed(char: String) -> void:
	add_character_def(char, 1, selected_ikemen_go_folder + select_def_path)


func _on_remove_def_pressed(char: String) -> void:
	remove_character_def(char, selected_ikemen_go_folder + select_def_path)


func _on_remove_pressed(char: String) -> void:
	if not DirAccess.dir_exists_absolute(selected_ikemen_go_folder + chars_path + "/" + char):
		printerr("Character doesnt exist in chars folder!")
		return
	
	OS.move_to_trash(selected_ikemen_go_folder + chars_path + "/" + char)
	remove_character_def(char, selected_ikemen_go_folder + select_def_path)


func _on_load_archive_pressed() -> void:
	archive_open_folder.popup_centered()


func _on_file_dialog_dir_selected(dir: String) -> void:
	archive_folder = dir
	print("Set archive folder!")
	
	clear_characters_list()
	load_character_list(archive_folder + archive_characters_path)


func _on_open_folder_pressed() -> void:
	if not archive_folder:
		printerr("Archive folder has not been set!")
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
			OS.shell_open(archive_folder + archive_characters_path + "/" + misc_context.selected_char)
