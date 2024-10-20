extends RefCounted

# Functions for modifying ikemen go's file.

static func add_new_line(text: String, line: int, ref: String) -> String:
	var ref_split = ref.split("\n")
	ref_split.insert(max(line - 1, 0), text)
	var final: String
	
	final = "\n".join(ref_split)
	
	return final

static func remove_line(line: int, ref: String) -> String:
	var ref_split = ref.split("\n")
	ref_split.remove_at(max(line - 1, 0))
	var final: String
	
	final = "\n".join(ref_split)
	
	return final

static func copy_paste_to(path_from: String, path_to: String) -> void:
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
			copy_paste_to(path_from + "/" + file_name, path_to + "/" + file_name)
		else:
			files += 1
			print("Found file: " + path_from + "/" + file_name)
			DirAccess.copy_absolute(path_from + "/" + file_name, path_to + "/" + file_name) 
		file_name = dir.get_next()
	
	print("\n")
	print("Path from: " + path_from + " will copy to: " + path_to)
	print("Files found: " + str(files))
	print("Directories found: " + str(directories))

static func add_character_def(char: String, slot: int, path: String, start_line: int = 196) -> void: # Adds character to select.def file
	if char.is_empty():
		printerr("add_character_def: char argument is empty!")
		return
	
	if char.is_empty():
		printerr("add_character_def: path argument is empty!")
		return
	
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

# NOTE: Path must be the location to the Ikemen GO folder and not to chars folders!
static func remove_character(char: String, char_folder: String, select_file: String, start_line: int = 196) -> void:
	var not_allowed = ["randomselect"]
	
	if !DirAccess.dir_exists_absolute(char_folder + "/" + char):
		printerr("Character ", char, " doesn't exist in ", char_folder, "!")
		return
	
	if !FileAccess.file_exists(select_file):
		printerr("Select file path doesn't exist!")
		return
	
	if not char in not_allowed:
		OS.move_to_trash(char_folder + "/" + char)
	
	remove_character_def(char, select_file, start_line)

static func remove_character_def(char: String, path: String, start_line: int = 196) -> void:
	if char.is_empty():
		printerr("add_character_def: char argument is empty!")
		return
	
	if path.is_empty():
		printerr("add_character_def: char argument is empty!")
		return
	
	var select_ikemen = FileAccess.open(path, FileAccess.READ)
	if select_ikemen == null:
		print("invalid path!!")
		return
	
	var ref = select_ikemen.get_as_text()
	
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
	
	#print(char_ids)
	#print(characters)
	
	select_ikemen = FileAccess.open(path, FileAccess.WRITE)
	select_ikemen.store_string(remove_line(remove_id_line, ref))
	select_ikemen.close()

# CLears all the characters from def
static func clear_characters_def_list(path: String, start_line: int = 196) -> void:
	var list = get_char_list_absolute_file(start_line, path)
	
	if list == []:
		print("The character list is empty!")
		return
	
	for k in list:
		remove_character_def(k, path, start_line)

static func get_char_list_file(start: int, path: String) -> Array:
	var select_ikemen = FileAccess.open(path, FileAccess.READ)
	if select_ikemen == null:
		print("Invalid path!")
		return []
	
	var ref = select_ikemen.get_as_text()
	select_ikemen.close()
	
	return get_char_list(start, ref)

static func get_char_list(start: int, ref: String) -> Array:
	var ref_split = ref.split("\n")
	var array: Array
	var id = start
	var characters_ids: Array
	
	for k in ref_split:
		if ref_split[id - 1].strip_escapes().is_empty(): # end for statement if line is empty
			break
		
		array.append(ref_split[id - 1].strip_escapes())
		characters_ids.append(id)
		id += 1
	
	return array

static func get_char_list_absolute_file(start: int, path: String) -> Array:
	var select_ikemen = FileAccess.open(path, FileAccess.READ)
	if select_ikemen == null:
		print("Invalid path!")
		return []
	
	var ref = select_ikemen.get_as_text()
	select_ikemen.close()
	
	return get_char_list_absolute(start, ref)

# Gets characters that are on characters folder
static func get_all_char_list(folder: String) -> Array:
	var characters = DirAccess.get_directories_at(folder)
	return characters

static func get_char_list_absolute(start: int, ref: String) -> Array:
	var array: Array = get_char_list(start, ref)
	var characters: Array
	
	for k in array:
		characters.append(k.split(",")[0])
	
	# ID references:
	# 0 = character
	# 1 = character's stage
	# 2 = order
	
	
	return characters

static func get_char_list_id_file(start: int, path: String) -> Array:
	var select_ikemen = FileAccess.open(path, FileAccess.READ)
	if select_ikemen == null:
		print("Invalid path!")
		return []
	
	var ref = select_ikemen.get_as_text()
	select_ikemen.close()
	
	return get_char_list_id(start, ref)

static func get_char_list_id(start: int, ref: String) -> Array:
	var ref_split = ref.split("\n")
	var id = start
	var characters_ids: Array
	
	for k in ref_split:
		if ref_split[id - 1].is_empty(): # end for statement if line is empty
			break
		
		characters_ids.append(id)
		id += 1
	
	return characters_ids
