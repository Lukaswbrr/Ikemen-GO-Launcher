@tool
extends EditorScript

var _has_found_subchild = false

# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	pass

func dir_contents_except(path: String, folder_except: PackedStringArray, files_except: PackedStringArray) -> void: # Prints current contents of folder
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
			
			if file_name in folder_except:
				print("It's in folder except!")
				file_name = dir.get_next()
			
			dir_contents_except(path + "/" + file_name, folder_except, files_except)
		else:
			files += 1
			print("Found file " + path + "/" + file_name)
			if file_name in files_except:
				print("it's in files except!")
			
			
		file_name = dir.get_next()
	
	print("\n")
	print("Path: " + path)
	print("Files found: " + str(files))
	print("Directories found: " + str(directories))

func temp_create(path: String) -> void:
	if path.is_empty():
		print("The TEMP creation path is empty!")
		return
	
	if DirAccess.dir_exists_absolute(path + "/" + "TEMP"):
		print("TEMP already exists!")
		return
	
	DirAccess.make_dir_absolute(path + "/" + "TEMP")
	pass

func copy_paste_only(path: String, folder_only: PackedStringArray, file_only: PackedStringArray, to_path: String) -> void:
	if path.is_empty():
		print("The path is empty!")
		return
	
	if to_path.is_empty():
		print("The to path is empty!")
		return
	
	if !folder_only.is_empty():
		_copy_paste_folder_only(path, folder_only, to_path)
	
	if !file_only.is_empty():
		_copy_paste_file_only(path, file_only, to_path)

func _copy_paste_file_only(path: String, files_only: PackedStringArray, to_path: String) -> void:
	for k in files_only:
		print("File (" + k + ") exists?: " + str(FileAccess.file_exists(path + "/" + k)))

func _copy_paste_folder_only(path: String, folder_only: PackedStringArray, to_path: String) -> void:
	var dir = DirAccess.open(path)
	if !dir:
		print("An error occurred when trying to access the path.")
		return

	var files: int
	var directories: int
	var path_split = path.split("/")
	
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "" and file_name != "..":
		if dir.current_is_dir():
			if file_name in ["TEMP"]:
				print("Folder name is TEMP, skipping")
				print("TEMP Path: " + path + "/" + file_name)
				file_name = dir.get_next()
			
			directories += 1
			print("\n")
			print("Found directory: " + path + "/" + file_name)
			
			if file_name in folder_only:
				print("It's in folder only!")
				_copy_paste_folder_only(path + "/" + file_name, folder_only, to_path)
			else:
				for k in folder_only:
					if not k in path_split:
						print(k + " not found on path_split")
						continue
					
					if k in path_split:
						print(k , " is sub child of folder only!")
						_copy_paste_folder_only(path + "/" + file_name, folder_only, to_path)
						_has_found_subchild = true
			
			if !file_name in folder_only and !_has_found_subchild:
				print("Not in folder only and has not found any sub child.")
			
			_has_found_subchild = false
			
		else:
			files += 1
			print("Found file " + path + "/" + file_name)
			
			
		file_name = dir.get_next()
	
	print("\n")
	print("Path: " + path)
	print("Files found: " + str(files))
	print("Directories found: " + str(directories))
