tool
extends EditorPlugin

const PaletteSwapInspector : = preload("PaletteSwapTextureInspector.gd")
const PaletteSwapTexture : = preload("PaletteSwapTexture.gd")
const ICON : = preload("icon_proxy_texture.svg")

var palette_inspector : = PaletteSwapInspector.new()

func _enter_tree():
	palette_inspector.editor_file_system = get_editor_interface().get_resource_filesystem()
	add_custom_type("PaletteSwapTexture", "ProxyTexture", PaletteSwapTexture, ICON)
	add_inspector_plugin(palette_inspector)

func _exit_tree():
	remove_custom_type("PaletteSwapTexture")
	remove_inspector_plugin(palette_inspector)