extends Window

@onready var tree = $TabContainer/Characters/Tree
@onready var ikemen_files = preload("res://scripts/file_stuff.gd")

var character_id = 0
var group_names = ["All", "On select.def", "Not on select.def"]
@onready var add_context = $AddContext

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = tree.create_item()
	tree.hide_root = true
	var child1 = tree.create_item(root)
	child1.set_text(0, "All")
	var child2 = tree.create_item(root)
	child2.set_text(0, "On select.def")
	var child3 = tree.create_item(root)
	child3.set_text(0, "Not on select.def")
	
	
	#for k in 5:
		#var new_child = tree.create_item(child1)
		#new_child.set_text(0, str(k))
	#
	#for k in child1.get_child_count():
		#var copy_child = tree.create_item(child3)
		#copy_child.set_text( 0, child1.get_children()[k].get_text(0))
		#
	#print(child1.get_children())


func clear_characters_list() -> void:
	for k in tree.get_root().get_children():
		for m in k.get_children():
			m.free()

func load_characters_list(character_folder: String, select: String) -> void:
	if character_folder.is_empty():
		printerr("load_characters_list: Character folder argument is empty!")
		return
	
	if select.is_empty():
		printerr("load_characters_list: Select path argument is empty!")
		return
	
	var all_char = ikemen_files.get_all_char_list(character_folder)
	var char_select = ikemen_files.get_char_list_absolute_file(196, select)
	
	var not_on_select = []
	
	for k in all_char:
		if k in char_select:
			continue
		not_on_select.append(k)
	
	print("Characters on select group: ", str(char_select))
	print("Characters not on select group: ", str(not_on_select))
	
	for k in all_char:
		var new_item = tree.create_item(tree.get_root().get_child(0))
		new_item.set_text(0, k)
	
	for k in char_select:
		var new_item = tree.create_item(tree.get_root().get_child(1))
		new_item.set_text(0, k)
	
	for k in not_on_select:
		var new_item = tree.create_item(tree.get_root().get_child(2))
		new_item.set_text(0, k)

# Clears and loads character list
func refresh_character_list(character_folder: String, select: String) -> void:
	clear_characters_list()
	load_characters_list(character_folder, select)

func _on_move_to_pressed() -> void:
	if tree.get_selected() == null:
		printerr("No item selected!")
		return
	
	if tree.get_selected().get_text(0) in group_names:
		printerr("Can't move groups!")
		return
	
	print("The column is: " + str(tree.get_selected_column()))
	print("The item is: " + str(tree.get_selected()))
	print("The item name is: " + str(tree.get_selected().get_text(0)))
	print("The parent of the item is: " + str(tree.get_selected().get_parent().get_text(0)))
	
	var tree_root = tree.get_root()
	var select_group = tree_root.get_child(1)
	var not_select_group = tree_root.get_child(2)
	var parent_item = null
	
	if not tree.get_selected() == null:
		parent_item = tree.get_selected().get_parent()
	
	if parent_item.get_text(0) == "All":
		print(tree.get_children())
		
		for k in select_group.get_child_count():
			if select_group.get_children()[k].get_text(0) == tree.get_selected().get_text(0):
				print("This item is already in select def!")
				return
	
	if parent_item.get_text(0) == "On select.def":
		print("It's already on select def!")
		return
	
	var new_item = tree.create_item(select_group)
	new_item.set_text(0, tree.get_selected().get_text(0))
	
	if parent_item.get_text(0) == "All":
		for k in not_select_group.get_child_count():
			if not_select_group.get_child(k).get_text(0) == tree.get_selected().get_text(0):
				not_select_group.get_child(k).free()
				break
	else:
		tree.get_selected().free()

func _on_move_away_pressed() -> void:
	if tree.get_selected() == null:
		printerr("No item selected!")
		return
	
	if tree.get_selected().get_text(0) in group_names:
		printerr("Can't move groups!")
		return
	
	print("The column is: " + str(tree.get_selected_column()))
	print("The item is: " + str(tree.get_selected()))
	print("The item name is: " + str(tree.get_selected().get_text(0)))
	print("The parent of the item is: " + str(tree.get_selected().get_parent().get_text(0)))
	
	var tree_root = tree.get_root()
	var all_group = tree_root.get_child(0)
	var select_group = tree_root.get_child(1)
	var not_select_group = tree_root.get_child(2)
	var parent_item = null
	
	if not tree.get_selected() == null:
		parent_item = tree.get_selected().get_parent()
	
	if parent_item.get_text(0) == "All":
		print(tree.get_children())
		
		for k in not_select_group.get_child_count():
			if not_select_group.get_child(k).get_text(0) == tree.get_selected().get_text(0):
				print("This item is already not in select def!")
				return
	
	if parent_item.get_text(0) == "Not on select.def":
		print("It's already not on select def!")
		return
	
	var new_item = tree.create_item(not_select_group)
	new_item.set_text(0, tree.get_selected().get_text(0))
	
	if parent_item.get_text(0) == "All":
		for k in select_group.get_child_count():
			if select_group.get_child(k).get_text(0) == tree.get_selected().get_text(0):
				select_group.get_child(k).free()
				break
	else:
		tree.get_selected().free()


func _on_remove_pressed() -> void:
	#OS.alert("When using remove, it will remove the character from the ikemen go folder! (The file will be moved to the trash bin in your system)", "Warning!")
	
	if tree.get_selected() == null:
		printerr("No item selected!")
		return
	
	if tree.get_selected().get_text(0) in group_names:
		printerr("Can't move groups!")
		return
	
	var tree_root = tree.get_root()
	var all_group = tree_root.get_child(0)
	var select_group = tree_root.get_child(1)
	var not_select_group = tree_root.get_child(2)
	var parent_item = null
	
	if not tree.get_selected() == null:
		parent_item = tree.get_selected().get_parent()
	
	
	match tree.get_selected().get_parent().get_text(0):
		"All":
			for k in select_group.get_children():		
				if k.get_text(0) == tree.get_selected().get_text(0):
					k.free()
			
			for k in not_select_group.get_children():
				if k.get_text(0) == tree.get_selected().get_text(0):
					k.free()
			
			tree.get_selected().free()
		"On select.def":
			for k in all_group.get_children():		
				if k.get_text(0) == tree.get_selected().get_text(0):
					k.free()
			
			for k in not_select_group.get_children():
				if k.get_text(0) == tree.get_selected().get_text(0):
					k.free()
			
			tree.get_selected().free()
		"Not on select.def":
			for k in all_group.get_children():		
				if k.get_text(0) == tree.get_selected().get_text(0):
					k.free()
			
			for k in select_group.get_children():
				if k.get_text(0) == tree.get_selected().get_text(0):
					k.free()
			
			tree.get_selected().free()
	

func _on_add_pressed() -> void:
	_open_add_context()

func _open_add_context():
	add_context.popup(Rect2i(DisplayServer.mouse_get_position().x - 100, DisplayServer.mouse_get_position().y - 75, 0, 0))
