extends Tree


# Internal functions for handling drag and drop system
func _get_drag_data(position):
	# Use a control that is not in the tree
	var items: Array
	var next: TreeItem = get_next_selected(null)
	
	var preview = VBoxContainer.new()
	
	while next:
		if get_selected().get_parent() == next.get_parent():
			items.append(next)
			var label = Label.new()
			label.set_text(next.get_text(0))
			preview.add_child(label)
		next = get_next_selected(next)
		
	print(items)
	set_drag_preview(preview)
	return items

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	drop_mode_flags = Tree.DROP_MODE_INBETWEEN
	var drop_section = get_drop_section_at_position(at_position)
	var not_allowed_items = ["On select.def", "Not on select.def", "All"]
	
	if drop_section == 1:
		print("Below!")
	elif drop_section == 0:
		print("On item!")
	else:
		print("Above!")
	
	if drop_section == -100:
		return false
	
	
	var item = get_item_at_position(at_position)
	print("Item name: " + item.get_text(0))
	print("Item's parent is: " + item.get_parent().get_text(0))
	
	if item in data:
		print("The current selected item is in data!")
		return false
	
	# TODO: Implement a way to add items inside groups
	if item.get_parent() == get_root():
		if drop_section == -1 or drop_section == 1 or drop_section == 0:
			print("Can't drag outside of groups!")
			return false
	
	for k in data:
		if k.get_text(0) in not_allowed_items:
			print("Can't drag groups!")
			return false
		
		# INFO: Unallows dragging to a new section, if i implement a way to add
		# items inside groups, remove this
		if !k.get_parent() == item.get_parent():
			print("Can't drag to groups! (yet)")
			return false
	
	if item.get_text(0) == "All" or item.get_parent().get_text(0) == "All":
		print("Can't drag inside All group!")
		return false
	
	
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var group_names = ["All", "On select.def", "Not on select.def"]
	var drop_section = get_drop_section_at_position(at_position)
	var other_item = get_item_at_position(at_position)
	var item_group: Array
	
	print("\n")
	print("It will drop in section: " + str(drop_section))
	print("Item will drop at: " + str(other_item.get_text(0)))
	
	
	for item in data:
		item_group.append(item)
	
	for i in data.size():
		var item: TreeItem = data[i]
		
		print(other_item.get_child_count())
		
		# Create new item if there is none in group
		# TODO: Implement a way to add items inside groups
		# Currently disabled since i don't know how to do this yet
		
		#if other_item.get_child_count() < 1 and other_item.get_text(0) in group_names:
		#	var new_item = create_item(other_item)
		#	new_item.set_text(0, item.get_text(0))
		#	continue
		
		#if item.get_parent().get_text(0) == "All":
		#	print("It's in all!")
		#	var new_item = create_item(get_root().get_child(0))
		#	new_item.set_text(0, item.get_text(0))
		
		match drop_section:
			-1:
				item.move_before(other_item)
			1:
				if i == 0:
					item.move_after(other_item)
				else:
					item.move_after(data[i - 1])
