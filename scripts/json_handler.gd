extends GDScript

## Handles json stuff

static var create_ikemen_default_config = {
	"authorName" = "",
	"commit" = "",
	"timeCreated" = "",
	"timeVersion" = "",
	"coverImage" = "",
	"coverDisplayName" = "",
	"displayName" = "",
	"musicAutoplay" = true,
	"musicFile" = "",
	"musicDisplayName" = "",
	"launcherColors" = "",
	"tags" = [],
	"operating_system" = "",
	"date_created" = "",
	"date_version" = ""
}

static var old_launcher_configuration_default = {
	"autoLoadFolders" = false,
	"autoUnzip" = false,
	"playFolder" = "",
	"downloadFolder" = ""
}

static var launcher_configuration_default = {
	"autoLoadFolders" = false,
	"autoUnzip" = true,
	"keepIKEMENZipDownload" = false,
	"loadFolders" = "",
	"automaticSetAutoLoad" = true,
	"keepIKEMENZipUpdate" = false,
	"keepTEMPFolder" = false,
}

static var archive_configuration_default = {
	"archiveAutoLoad" = false,
	"archiveFolder" = "",
	"selectStartLine" = 196
}


static func create_save(file: String, dictionary: Dictionary) -> void:
	if FileAccess.file_exists("user://" + file):
		#print("save file exists, returning")
		return
	
	var json = JSON.stringify(dictionary, "\t")
	var new_file = FileAccess.open("user://" + file, FileAccess.WRITE)
	new_file.store_string(json)
	#print(json)

static func update_save(file: String, dict: Dictionary) -> void:
	if !FileAccess.file_exists("user://" + file):
		print("file doesn't exist!")
		return
	
	var json = JSON.stringify(dict, "\t")
	var new_file = FileAccess.open("user://" + file, FileAccess.WRITE)
	new_file.store_string(json)

static func load_autosave(file: String) -> Dictionary:
	if !FileAccess.file_exists("user://" + file):
		print("file doesn't exist!")
		return {}
	
	var json = JSON.new()
	var error = json.parse(FileAccess.get_file_as_string("user://" + file))
	return json.data
