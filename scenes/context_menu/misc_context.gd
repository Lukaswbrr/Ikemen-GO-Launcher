extends PopupMenu

var selected_char: String

func _on_id_pressed(id: int) -> void:
	print(id)
	match id:
		0:
			print("selected character folder")
