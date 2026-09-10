# *************************************************
# Steam Cloud save/load, with a local-disk fallback
# so saving still works when not running under Steam.
# *************************************************

extends Node

const PROGRESS_FILE := "dystopia_progress.dat"

func _cloud_available() -> bool:
	return Steam.loggedOn() and Steam.isCloudEnabledForApp() and Steam.isCloudEnabledForAccount()


func write_file(file_name: String, data: Dictionary) -> bool:
	var bytes := JSON.stringify(data).to_utf8_buffer()

	var local := FileAccess.open("user://" + file_name, FileAccess.WRITE)
	if local == null:
		push_error("SteamCloud: failed to open local file for write: " + file_name)
		return false
	local.store_buffer(bytes)
	local.close()

	if _cloud_available():
		var ok: bool = Steam.fileWrite(file_name, bytes)
		if not ok:
			push_error("SteamCloud: Steam.fileWrite failed for " + file_name)
		return ok

	return true


func read_file(file_name: String) -> Dictionary:
	if _cloud_available() and Steam.fileExists(file_name):
		var result: Dictionary = Steam.fileRead(file_name, Steam.getFileSize(file_name))
		if result.get("ret", false):
			var parsed = JSON.parse_string(result.get("buf", PackedByteArray()).get_string_from_utf8())
			if typeof(parsed) == TYPE_DICTIONARY:
				return parsed

	if FileAccess.file_exists("user://" + file_name):
		var local := FileAccess.open("user://" + file_name, FileAccess.READ)
		var parsed = JSON.parse_string(local.get_as_text())
		local.close()
		if typeof(parsed) == TYPE_DICTIONARY:
			return parsed

	return {}


func save_progress() -> bool:
	return write_file(PROGRESS_FILE, {
		"kill_count": Globals.kill_count,
		"current_level": Globals.current_level,
		"spawn_x": Globals.spawn_x,
		"spawn_y": Globals.spawn_y,
		"player_hitpoints": Globals.player_hitpoints,
		"direction_control": Globals.direction_control,
	})


func load_progress() -> Dictionary:
	return read_file(PROGRESS_FILE)
