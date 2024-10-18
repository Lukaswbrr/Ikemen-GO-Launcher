extends Control

signal cancel_operation
signal skip_operation
signal create_default_operation
signal create_custom_operation

var _selected_folder: String
@onready var _desc_original_text: String = $Desc.get_text()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func select_folder(folder: String):
	_selected_folder = folder
	$Desc.set_text(_desc_original_text % folder)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_skip_pressed() -> void:
	set_visible(false)
	emit_signal("skip_operation")


func _on_create_default_pressed() -> void:
	set_visible(false)
	emit_signal("create_default_operation")
