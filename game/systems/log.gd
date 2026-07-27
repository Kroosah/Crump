class_name Log
extends Object
## Log — centraal loghulpje (statische klasse, bewust géén autoload: geen
## node-lifecycle nodig en het houdt het autoload-aantal klein, D-012).
## Schrijft naar console én user://logs/ met rotatie. Debug-niveau bestaat
## alleen in debugbuilds. Vervangt losse print()-statements
## (CODING_STANDARDS §3.6) — dit is de enige plek die zelf print.

const LOG_DIR := "user://logs"
const MAX_LOG_FILES := 5

enum Level { DEBUG, INFO, WARN, ERROR }

static var _file: FileAccess = null
static var _current_path := ""


static func debug(message: String) -> void:
	if OS.is_debug_build():
		_write(Level.DEBUG, message)


static func info(message: String) -> void:
	_write(Level.INFO, message)


static func warn(message: String) -> void:
	_write(Level.WARN, message)
	push_warning(message)


static func error(message: String) -> void:
	_write(Level.ERROR, message)
	push_error(message)


## Pad van het actieve logbestand (leeg tot de eerste regel geschreven is).
static func get_current_log_path() -> String:
	return _current_path


static func _write(level: Level, message: String) -> void:
	var stamp := Time.get_datetime_string_from_system(false, true)
	var line := "%s [%s] %s" % [stamp, _level_name(level), message]
	# Bewuste console-uitvoer: Log ís de toegestane print-plek.
	print(line)
	_ensure_file()
	if _file != null:
		_file.store_line(line)
		_file.flush()  # per regel: bij een crash is de log compleet


static func _level_name(level: Level) -> String:
	match level:
		Level.DEBUG: return "DEBUG"
		Level.INFO: return "INFO"
		Level.WARN: return "WARN"
		Level.ERROR: return "ERROR"
	return "?"


static func _ensure_file() -> void:
	if _file != null:
		return
	DirAccess.make_dir_recursive_absolute(LOG_DIR)
	_rotate()
	var stamp := Time.get_datetime_string_from_system().replace(":", "-")
	_current_path = "%s/crump_%s.log" % [LOG_DIR, stamp]
	_file = FileAccess.open(_current_path, FileAccess.WRITE)
	if _file == null:
		push_error("Log: kan logbestand niet openen: %s" % _current_path)


## Houdt maximaal MAX_LOG_FILES-1 oude logs over (plus de nieuwe = MAX).
static func _rotate() -> void:
	var dir := DirAccess.open(LOG_DIR)
	if dir == null:
		return
	var logs: Array[String] = []
	for file_name in dir.get_files():
		if file_name.begins_with("crump_") and file_name.ends_with(".log"):
			logs.append(file_name)
	logs.sort()  # timestamp in de naam = chronologisch sorteerbaar
	while logs.size() >= MAX_LOG_FILES:
		dir.remove(logs.pop_front())
