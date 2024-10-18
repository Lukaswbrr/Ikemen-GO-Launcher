@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).


func _run() -> void:
	var output = []
	#var error = OS.execute("pwd", [], output)
	#print(output)
	
	#run_bash()

func run_bash() -> void:
	var output = []
	var error = OS.execute("bash", ["moment.sh"], output)
	print(output)
