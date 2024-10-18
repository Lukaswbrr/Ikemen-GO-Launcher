extends HTTPRequest


var started: bool
var finished: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_body_size() == -1:
		return
	
	if finished:
		return
	
	if get_downloaded_bytes() == get_body_size():
		finished = true
		print("finished")
		return
	
	print("body size " + str(get_body_size()))
	print("downloaded " + str(get_downloaded_bytes()))
