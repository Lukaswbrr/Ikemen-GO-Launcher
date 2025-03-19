extends HTTPRequest

## Handles http requests
const format = preload("res://scripts/format_stuff.gd")

@onready var download_http: HTTPRequest = $Download

var requested_data: Array
var request_finished: bool
var nightly_build_id: int

var ikemen_versions_id: Dictionary

func _ready() -> void:
	pass

func request_data() -> void:
	var error = request("https://api.github.com/repos/ikemen-engine/Ikemen-GO/releases")
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func hello() -> void:
	print("jj")

func download_ikemen_go(path: String, os: String, version: String) -> void:
	# INFO: This needs to be updated that it uses the requested_data variable
	# in order to find the versions due to url not being consistent.
	# or not idk
	download_http.set_download_file(path)
	
	if not download_http.download_file:
		print("There's no download file setted!")
		return
	
	var all_files_versions = ["v0.98.2", "v0.98.1", "v0.98.0", "v0.97.0"]
	var url: String
	
	if version in all_files_versions:
		if version == "v0.98.0":
			# theres no .0 at the end for some reason!
			url = "https://github.com/ikemen-engine/Ikemen-GO/releases/download/" + version + "/Ikemen_GO_v0.98" + ".zip"
		else:
			url = "https://github.com/ikemen-engine/Ikemen-GO/releases/download/" + version + "/Ikemen_GO_" + version + ".zip"
			print(url)
	else:
		match os:
			"Windows":
				if version == "nightly":
					url = "https://github.com/ikemen-engine/Ikemen-GO/releases/download/nightly/Ikemen_GO-dev-windows.zip"
				else:
					url = "https://github.com/ikemen-engine/Ikemen-GO/releases/download/" + version + "/Ikemen_GO-" + version + "-windows.zip"
			"Linux":
				if version == "nightly":
					url = "https://github.com/ikemen-engine/Ikemen-GO/releases/download/nightly/Ikemen_GO-dev-linux.zip"
				else:
					url = "https://github.com/ikemen-engine/Ikemen-GO/releases/download/" + version + "/Ikemen_GO-" + version + "-linux.zip"
			_:
				print("Invalid OS!")
				return
	
	
	var error = download_http.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request. Error ID: " + str(error) + ", URL: " + url)
	else:
		download_http.started = true
	

func check_version() -> bool:
	return true

func get_latest_nightly_version_date(os: String) -> String:
	var date = get_requested_data_nightly(os)["updated_at"]
	var final_date = " ".join(format.format_date_array(date))
	
	return final_date

func get_requested_data_nightly(os: String) -> Dictionary:
	match os:
		"Windows":
			return requested_data[nightly_build_id]["assets"][0]
		"Linux":
			return requested_data[nightly_build_id]["assets"][2]
		_:
			return {}

func get_requested_data_key_nightly(os: String, key):
	match os:
		"Windows":
			return requested_data[nightly_build_id]["assets"][0][key]
		"Linux":
			return requested_data[nightly_build_id]["assets"][2][key]
		_:
			return {}

func get_requested_data_version(version: String):
	return requested_data[ikemen_versions_id[version]]

func get_requested_data_assets_version(version: String):
	return requested_data[ikemen_versions_id[version]]["assets"]

func get_requested_data_assets_os_version(version: String, os: String):
	var all_files_versions = ["v0.98.2", "v0.98.1", "v0.98.0", "v0.97.0"]
	
	if version in all_files_versions:
		return get_requested_data_assets_version(version)[0]
	
	match os:
		"Windows":
			return get_requested_data_assets_version(version)[0]
		"Linux":
			return get_requested_data_assets_version(version)[2]

func _process(delta: float) -> void:
	pass


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	var id: int
	
	# searches for the nightly build
	for k in response:
		ikemen_versions_id[k["name"]] = id
		
		if k["name"] == "nightly":
			nightly_build_id = id
			print_rich("[color=purple]The nightly build is ID " + str(id) + "!!![/color]")
		
		id += 1
	
	requested_data = response
	request_finished = true
	#print(ikemen_versions_id)
	#print(requested_data[7])
	print_rich("[color=green]Finished HTTP fetch request![/color]")
