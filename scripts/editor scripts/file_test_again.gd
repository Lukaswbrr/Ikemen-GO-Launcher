@tool
extends EditorScript


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
