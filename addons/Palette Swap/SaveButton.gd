extends Button

var object : Object
var file_dialog : = EditorFileDialog.new()
var file_system : EditorFileSystem

func _init(obj : Object, file_sys : EditorFileSystem):
	object = obj
	file_system = file_sys

	text = "Save to Image"
	connect("resized", self, "on_resized")
	connect("pressed", self, "on_pressed")

	file_dialog.add_filter("*.png ; PNG Images")
	file_dialog.connect("file_selected", self, "on_file_selected")
	add_child(file_dialog)

func on_pressed():
	file_dialog.invalidate()
	file_dialog.popup_centered_ratio()

func on_file_selected(path : String):
	var image : Image = object.base.get_data()
	image.save_png(path)
	file_system.scan()

func on_resized():
	disconnect("resized", self, "on_resized")
	rect_position.x -= rect_size.x
	rect_size.x *= 2
	connect("resized", self, "on_resized")