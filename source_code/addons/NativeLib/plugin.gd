@tool
# Plugin NativeLib : MIT License
# @author DrMoriarty
extends EditorPlugin

const IconResource = preload("res://addons/NativeLib/icons/phone.svg")
const MainUI = preload("res://addons/NativeLib/MainUI.tscn")

var _main_ui

func _enter_tree():
	_main_ui = MainUI.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(_main_ui)
	_main_ui.set_editor(self)
	_make_visible(false)

func _exit_tree():
	if _main_ui:
		_main_ui.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if _main_ui:
		_main_ui.visible = visible

func _get_plugin_name():
	return "NativeLib"

func _get_plugin_icon():
	return IconResource

func _save_external_data():
	if _main_ui:
		_main_ui.save_data()
