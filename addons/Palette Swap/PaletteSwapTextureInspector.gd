extends EditorInspectorPlugin

const PaletteSwapTexture : = preload("PaletteSwapTexture.gd")
const SaveButton : = preload("SaveButton.gd")

var hidden_properties : = ["pixel_map", "base_palette", "base"]
var editor_file_system : EditorFileSystem

class EditorPropertyPalette extends EditorProperty:
	const PaletteEditMenu : = preload("PaletteEditMenu.gd")

	var palette_menu = PaletteEditMenu.new()
	var updating : = false

	func _init(object : Object):
		var base_tex_palette : PoolColorArray = object.get("base_palette")
		var swap_tex_palette : PoolColorArray = object.get("swap_palette")
		palette_menu.update_palette(base_tex_palette, swap_tex_palette)
		object.connect("texture_changed", palette_menu, "update_palette")
		palette_menu.connect("palette_changed", self, "on_palette_changed")
		add_child(palette_menu)

	func update_property():
		if not updating:
			var base : PoolColorArray = get_edited_object().get("base_palette")
			var swap : PoolColorArray = get_edited_object().get(get_edited_property())
			palette_menu.update_palette(base, swap)
		get_edited_object().update_palette()
		updating = false

	func on_palette_changed(new_palette : PoolColorArray):
		updating = true
		emit_changed(get_edited_property(), new_palette)

class EditorPropertyPreview extends EditorProperty:
	const TexturePreviewContainer : = preload("TexturePreviewContainer.gd")

	var tex_preview : TexturePreviewContainer

	func _init(object : Object):
		tex_preview = TexturePreviewContainer.new(object.get("base"))
		object.connect("palette_updated", tex_preview, "on_palette_updated")
		add_child(tex_preview)

func can_handle(object : Object):
	return object is PaletteSwapTexture

func parse_property(object : Object, type : int, path : String, hint : int, hint_text : String, usage : int):
	if hidden_properties.has(path):
		return true
	elif path == "swap_palette":
		var editor : = EditorPropertyPalette.new(object)
		add_property_editor(path, editor)
		return true
	return false

func parse_category(object : Object, category : String):
	if category == "ProxyTexture":
		var save_to_image : = EditorProperty.new()
		var button : = SaveButton.new(object, editor_file_system)
		save_to_image.add_child(button)
		add_custom_control(save_to_image)

		var texture_preview : = EditorPropertyPreview.new(object)
		add_custom_control(texture_preview)