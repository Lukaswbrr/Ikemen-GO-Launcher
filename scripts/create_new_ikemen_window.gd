extends Window
# TODO: When creating tags and other stuff, maybe use meta-data to store the tags? Check .launcher_godot folder and then store it on meta-data's game button idk

signal new_ikemen_created(project: Dictionary)
signal edit_ikemen(edit_ikemen, project: Dictionary)
signal remove_ikemen(name: String, should_delete_files: bool)
signal fetch_request()

@onready var scroll: ScrollContainer = $Control/ScrollContainer

@onready var ikemen_title_node: LineEdit = $Control/ScrollContainer/VBoxContainer/Title/LineEdit
@onready var album_display_node: LineEdit = $Control/ScrollContainer/VBoxContainer/AlbumDisplay/LineEdit
@onready var album_color_node: ColorPickerButton = $Control/ScrollContainer/VBoxContainer/AlbumColor/ColorPickerButton
@onready var album_text_color_node: ColorPickerButton = $Control/ScrollContainer/VBoxContainer/AlbumTextColor/ColorPickerButton
@onready var should_album_display_text_node: CheckButton = $Control/ScrollContainer/VBoxContainer/AlbumDisplayTextOption/CheckButton
@onready var background_color_node: ColorPickerButton = $Control/ScrollContainer/VBoxContainer/BackgroundColor/ColorPickerButton
@onready var title_color_node: ColorPickerButton = $Control/ScrollContainer/VBoxContainer/TitleColor/ColorPickerButton
@onready var description_color_node: ColorPickerButton = $Control/ScrollContainer/VBoxContainer/DescriptionColor/ColorPickerButton
@onready var description_node: LineEdit = $Control/ScrollContainer/VBoxContainer/Description/LineEdit
@onready var auto_update_node: CheckButton = $Control/ScrollContainer/VBoxContainer/AutoUpdate/CheckButton
@onready var executable_file_node: LineEdit = $Control/ScrollContainer/VBoxContainer/ExecutableFile/LineEdit
@onready var tags_node: LineEdit = $Control/ScrollContainer/VBoxContainer/Tags/LineEdit
@onready var location_node: LineEdit = $Control/ScrollContainer/VBoxContainer/Location/LineEdit
@onready var version_node: ItemList = $Control/ScrollContainer/VBoxContainer/Version/ItemList
@onready var system_node: ItemList = $Control/ScrollContainer/VBoxContainer/System/ItemList
@onready var ignore_update_folder_node: LineEdit = $Control/ScrollContainer/VBoxContainer/IgnoreUpdateFolder/LineEdit
@onready var ignore_update_file_node: LineEdit = $Control/ScrollContainer/VBoxContainer/IgnoreUpdateFile/LineEdit

@onready var create_button = $Control/ScrollContainer/VBoxContainer/Create
@onready var edit_button = $Control/ScrollContainer/VBoxContainer/Update
@onready var add_existent_ikemen_button = $Control/ScrollContainer/VBoxContainer/AddExistentIkemen

@onready var edit_only_nodes = [edit_button, $Control/ScrollContainer/VBoxContainer/ExecutableFile]

var selected_ikemen_edit
var edit_mode: bool

# Internal variables which are not meant to be modified by user
var date_created
var date_version


func test_item():
	var item_to_select = "nightly"
	
	for k in version_node.item_count:
		if version_node.get_item_text(k) == item_to_select:
			version_node.select(k)
			print(version_node.get_item_text(k))
			break

func create_ver() -> void:
	if visible:
		printerr("Window already visible!")
		return
	
	title = "Create new ikemen go game"
	edit_mode = false
	create_button.set_text("Create")
	
	for k in edit_only_nodes:
		k.set_visible(false)
	
	create_button.set_visible(true)
	add_existent_ikemen_button.set_visible(true)

func edit_ver() -> void:
	# FIXME: visible returns true, even though it's invisible for some reason.
	if visible:
		printerr("Window already visible!")
		return
	
	title = "Edit ikemen go game"
	edit_mode = true
	
	for k in edit_only_nodes:
		k.set_visible(true)
	
	create_button.set_visible(false)
	add_existent_ikemen_button.set_visible(false)

func load_values(dict: Dictionary) -> void:
	for k in dict:
		match k:
			"ikemen_name":
				ikemen_title_node.set_text(dict[k])
			"album_display":
				album_display_node.set_text(dict[k])
			"album_color":
				album_color_node.set_pick_color(dict[k])
			"album_text_color":
				album_text_color_node.set_pick_color(dict[k])
			"background_color":
				background_color_node.set_pick_color(dict[k])
			"ikemen_title_color":
				title_color_node.set_pick_color(dict[k])
			"desc_color":
				description_color_node.set_pick_color(dict[k])
			"desc":
				description_node.set_text(dict[k])
			"auto_update":
				auto_update_node.set_pressed(dict[k])
			"should_album_display_text":
				should_album_display_text_node.set_pressed(dict[k])
			"location":
				location_node.set_text(dict[k])
			"executable_file":
				executable_file_node.set_text(dict[k])
			"tags":
				tags_node.set_text(dict[k])
			"version":
				for version in version_node.item_count:
					if version_node.get_item_text(version) == dict[k]:
						version_node.select(version)
						print("The version node is: " + version_node.get_item_text(version))
						break
			"operating_system":
				for system in system_node.item_count:
					if system_node.get_item_text(system) == dict[k]:
						system_node.select(system)
						print("The system node is: " + system_node.get_item_text(system))
						break
			"ignore_update_folder":
				ignore_update_folder_node.set_text(dict[k])
			"ignore_update_file":
				ignore_update_file_node.set_text(dict[k])
			_:
				print(k)

func reset_values() -> void:
	ikemen_title_node.text = ""
	title_color_node.color = Color8(0, 0, 0)
	album_display_node.text = ""
	album_color_node.color = Color8(0, 0, 0)
	album_text_color_node.color = Color8(0, 0, 0)
	background_color_node.color = Color8(0,0,0)
	description_color_node.color = Color8(0,0,0)
	description_node.text = ""
	auto_update_node.button_pressed = false
	should_album_display_text_node.button_pressed = false
	executable_file_node.text = ""
	tags_node.text = ""
	location_node.text = ""
	
	version_node.deselect_all()
	system_node.deselect_all()
	
	selected_ikemen_edit = ""

func update_versions(versions: Array) -> void:
	$Control/ScrollContainer/VBoxContainer/Version/ItemList.clear()
	
	for k in versions:
		$Control/ScrollContainer/VBoxContainer/Version/ItemList.add_item(k)

func _on_create_pressed() -> void:
	if not version_node.is_anything_selected():
		OS.alert("A version hasn't been selected!")
		return
	
	if not system_node.is_anything_selected():
		OS.alert("You need to select a operating system!")
		return
	
	var ikemen_dictionary = {
		ikemen_name = ikemen_title_node.text,
		album_display = album_display_node.text,
		album_color = album_color_node.color,
		background_color = background_color_node.color,
		desc_color = description_color_node.color,
		ikemen_title_color = title_color_node.color,
		album_text_color = album_text_color_node.color,
		auto_update = auto_update_node.button_pressed,
		should_album_display_text = should_album_display_text_node.button_pressed,
		desc = description_node.text,
		executable_file = "",
		tags = tags_node.text,
		location = location_node.text,
		version = version_node.get_item_text(version_node.get_selected_items()[0]),
		operating_system = system_node.get_item_text(system_node.get_selected_items()[0]),
		"date_created" = Time.get_datetime_string_from_system(false, true),
		"date_version" = ""
	}
	
	# NOTE: Maybe add meta-data to button for album display name?
	# NOTE: Maybe merge create and update to same signal and use edit_mode variable to detect what it does
	
	if ikemen_dictionary["ikemen_name"].is_empty():
		OS.alert("Ikemen GO title is empty!")
		return
	
	if ikemen_dictionary["location"].is_empty():
		OS.alert("You need to insert a location!")
		return
	
	if ikemen_dictionary["album_display"].is_empty():
		ikemen_dictionary["album_display"] = ikemen_dictionary["ikemen_name"]
	
	if ikemen_dictionary["executable_file"].is_empty():
		match ikemen_dictionary["operating_system"]:
			"Windows":
				ikemen_dictionary["executable_file"] = "Ikemen_GO.exe"
			"Linux":
				ikemen_dictionary["executable_file"] = "Ikemen_GO_Linux"
	
	#print("Operating system is " + ikemen_dictionary["operating_system"])
	#print("Version is: " + ikemen_dictionary["version"])
	
	hide()
	emit_signal("new_ikemen_created", ikemen_dictionary)
	reset_values()
	scroll.set_v_scroll(0)


func _on_select_folder_pressed() -> void:
	$Control/ScrollContainer/VBoxContainer/Location/FileDialog.popup_centered()



func _on_file_dialog_dir_selected(dir: String) -> void:
	location_node.set_text(dir)


func _on_update_pressed() -> void:
	if not version_node.is_anything_selected():
		OS.alert("A version hasn't been selected!")
		return
	
	if not system_node.is_anything_selected():
		OS.alert("You need to select a operating system!")
		return
	
	var ikemen_dictionary = {
		ikemen_name = ikemen_title_node.text,
		album_display = album_display_node.text,
		album_color = album_color_node.color,
		background_color = background_color_node.color,
		desc_color = description_color_node.color,
		ikemen_title_color = title_color_node.color,
		album_text_color = album_text_color_node.color,
		auto_update = auto_update_node.button_pressed,
		should_album_display_text = should_album_display_text_node.button_pressed,
		desc = description_node.text,
		executable_file = executable_file_node.text,
		tags = tags_node.text,
		location = location_node.text,
		version = version_node.get_item_text(version_node.get_selected_items()[0]),
		operating_system = system_node.get_item_text(system_node.get_selected_items()[0])
	}
	
	# NOTE: Maybe add meta-data to button for album display name?
	
	
	if ikemen_dictionary["ikemen_name"].is_empty():
		OS.alert("Ikemen GO title is empty!")
		return
	
	if ikemen_dictionary["location"].is_empty():
		OS.alert("You need to insert a location!")
		return
	
	if ikemen_dictionary["album_display"].is_empty():
		ikemen_dictionary["album_display"] = ikemen_dictionary["ikemen_name"]
	
	if ikemen_dictionary["executable_file"].is_empty():
		match ikemen_dictionary["operating_system"]:
			"Windows":
				ikemen_dictionary["executable_file"] = "Ikemen_GO.exe"
			"Linux":
				ikemen_dictionary["executable_file"] = "Ikemen_GO_Linux"
	
	hide()
	
	print("The operating system is: " + ikemen_dictionary["operating_system"])
	emit_signal("edit_ikemen", selected_ikemen_edit, ikemen_dictionary)
	reset_values()
	scroll.set_v_scroll(0)


func _on_fetch_pressed() -> void:
	emit_signal("fetch_request")
