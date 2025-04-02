extends Control

@onready var ikemen_files = preload("res://scripts/file_stuff.gd")
@onready var list_window: Window = $List/ListWindow
@onready var character_tree = $List/ListWindow/TabContainer/Characters/Tree

# Ikemen project variables
var ikemen_location: String
var ikemen_character_folder_path: String
var ikemen_select_path: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func setup_paths(location: String, character: String, select: String) -> void:
	ikemen_location = location
	ikemen_character_folder_path = character
	ikemen_select_path = select

func list_apply_characters(select_location: String) -> void:
	print("true!")

func _on_apply_pressed() -> void:
	print("Settings applied successfully!")
	print( ikemen_files.get_char_list_absolute_file(196, ikemen_select_path ))
	
	var character_tree_root = character_tree.get_root()
	var select_group = character_tree_root.get_child(1)
	var not_select_group = character_tree_root.get_child(2)
	var parent_item = null
	
	if not character_tree.get_selected() == null:
		parent_item = character_tree.get_selected().get_parent()
	
	ikemen_files.clear_characters_def_list(ikemen_select_path)
	
	for k in select_group.get_child_count():
		ikemen_files.add_character_def(select_group.get_child(k).get_text(0), k + 1, ikemen_select_path)

# Removes the character from ikemen game
func _on_remove_pressed() -> void:
	ikemen_files.remove_character(character_tree.get_selected().get_text(0), ikemen_character_folder_path, ikemen_select_path )


func _on_add_pressed() -> void:
	pass # Replace with function body.


func _on_list_window_close_requested() -> void:
	$List/ListWindow.hide()
	%ArchiveMenu.hide()
	%ArchiveMenu.clear_selected()


func _on_archive_menu_close_requested() -> void:
	%ArchiveMenu.hide()
	%ArchiveMenu.clear_selected()


func _on_add_character_folder_dir_selected(dir: String) -> void:
	var dir_split = dir.split("/")
	var character_name = dir_split[-1] # Gets the last element
	
	ikemen_files.add_character_def(character_name, 1, ikemen_select_path)
	ikemen_files.copy_paste_to(dir, ikemen_character_folder_path + "/" + character_name)
	list_window.refresh_character_list(ikemen_character_folder_path, ikemen_select_path)


func _on_archive_menu_add_character_button_pressed(character: String) -> void:
	print(character)
	print(%ArchiveMenu.selected_ikemen_go_folder)
	print(%ArchiveMenu.chars_path)
	
	print("To paths:")
	var to_path = %ArchiveMenu.selected_ikemen_go_folder + "/" + %ArchiveMenu.chars_path + "/" + character
	print(to_path)

	
	print("From paths:")
	var from_path = %ArchiveMenu.archive_folder + "/" + %ArchiveMenu.archive_characters_path + "/" + character
	print(from_path)
	list_window.clear_characters_list()
	ikemen_files.copy_paste_to(from_path, to_path)
	list_window.load_characters_list(ikemen_character_folder_path, ikemen_select_path)


func _on_refresh_pressed() -> void:
	list_window.refresh_character_list(ikemen_character_folder_path, ikemen_select_path)


func _on_list_pressed() -> void:
	list_window.popup_centered()


func _on_add_context_id_pressed(id: int) -> void:
	match id:
		0:
			%ArchiveMenu.popup_archive(ikemen_location)
		1:
			$List/ListWindow/AddCharacterFolder.popup_centered()
		2:
			ikemen_files.add_character_def("randomselect", 1, ikemen_select_path)
			list_window.refresh_character_list(ikemen_character_folder_path, ikemen_select_path)


func _on_update_pressed() -> void:
	$UpdatePanel.show_update_panel("checking")
