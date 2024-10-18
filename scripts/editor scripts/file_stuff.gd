@tool
extends EditorScript

var total_files: int
var total_folders: int

func _run() -> void:
	pass

func print_dir_contents_total(path: String) -> void:
	total_files = 0
	total_folders = 0
	dir_contents_total(path)
	print("Total Files: " + str(total_files))
	print("Total Folders: " + str(total_folders))

func copy_test(path_from: String, path_to: String) -> void:
	if path_from == path_to:
		printerr("Path from is same as path to!")
		return
	
	if DirAccess.dir_exists_absolute(path_to):
		printerr("Path to folder already exists!")
		return
	
	var dir = DirAccess.open(path_from)
	dir.set_include_hidden(false)
	if !dir:
		print("An error occurred when trying to access the path.")
		return
	
	dir.make_dir_recursive(path_to)
	
	var files: int
	var directories: int
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "" and file_name != "..":
		if dir.current_is_dir():
			directories += 1
			total_folders += 1
			print("\n")
			print("Found directory: " + path_from + "/" + file_name)
			copy_test(path_from + "/" + file_name, path_to + "/" + file_name)
		else:
			files += 1
			total_files += 1
			print("Found file: " + path_from + "/" + file_name)
			DirAccess.copy_absolute(path_from + "/" + file_name, path_to + "/" + file_name) 
		file_name = dir.get_next()
	
	print("\n")
	print("Path from: " + path_from + " will copy to: " + path_to)
	print("Files found: " + str(files))
	print("Directories found: " + str(directories))

func dir_contents(path: String) -> void: # Prints current contents of folder
	var dir = DirAccess.open(path)
	dir.set_include_hidden(false)
	if !dir:
		print("An error occurred when trying to access the path.")
		return

	var files: int
	var directories: int
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "" and file_name != "..":
		if dir.current_is_dir():
			directories += 1
			print("\n")
			print("Found directory: " + path + "/" + file_name)
			dir_contents(path + "/" + file_name)
		else:
			files += 1
			print("Found file " + path + "/" + file_name)
		file_name = dir.get_next()
	
	print("\n")
	print("Path: " + path)
	print("Files found: " + str(files))
	print("Directories found: " + str(directories))

func dir_contents_total(path: String) -> void: # Prints current contents of folder
	var dir = DirAccess.open(path)
	dir.set_include_hidden(false)
	if !dir:
		print("An error occurred when trying to access the path.")
		return

	var files: int
	var directories: int
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "" and file_name != "..":
		if dir.current_is_dir():
			directories += 1
			total_folders += 1
			print("\n")
			print("Found directory: " + path + "/" + file_name)
			dir_contents(path + "/" + file_name)
		else:
			files += 1
			total_files += 1
			print("Found file " + path + "/" + file_name)
		file_name = dir.get_next()
	
	print("\n")
	print("Path: " + path)
	print("Files found: " + str(files))
	print("Directories found: " + str(directories))

func add_new_line(text: String, line: int, ref: String) -> String:
	var ref_split = ref.split("\n")
	ref_split.insert(max(line - 1, 0), text)
	var final: String
	
	final = "\n".join(ref_split)
	
	return final

func remove_line(line: int, ref: String) -> String:
	var ref_split = ref.split("\n")
	ref_split.remove_at(max(line - 1, 0))
	var final: String
	
	final = "\n".join(ref_split)
	
	return final

func remove_character(char: String, path: String) -> void:
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
	
	print(char_ids)
	print(characters)
	
	var remove_id = characters.find(char)
	var remove_id_line = char_ids[remove_id]
	char_ids.remove_at(remove_id)
	characters.remove_at(remove_id)
	
	print(char_ids)
	print(characters)
	
	select_ikemen = FileAccess.open(path, FileAccess.WRITE)
	select_ikemen.store_string(remove_line(remove_id_line, ref))
	select_ikemen.close()

func add_character(char: String, slot: int, path: String) -> void: # Adds character to select.def file
	if slot < 1:
		print("invalid slot!")
		return
	
	var select_ikemen = FileAccess.open(path, FileAccess.READ)
	if select_ikemen == null:
		print("invalid path!!")
		return
	
	var ref = select_ikemen.get_as_text()
	
	var start_line = 196
	var char_ids = get_char_list_id(start_line, ref)
	var end_line: int = char_ids[max(char_ids.size() - 1, 0)] if char_ids.size() > 0 else 0
	
	var first_slot: int = 1
	var last_slot: int = char_ids.size()
	
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

func add_character_ikemen(charpath: String, slot: int, path: String) -> void:
	pass

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

func seek_line(line: int, str: String) -> int:
	var str_split = str.split("\n")
	var amount: int
	
	for k in str_split:
		if k == str_split[max(line - 1, 0)]:
			break
		
		amount += k.length()
	return amount + line - 1
