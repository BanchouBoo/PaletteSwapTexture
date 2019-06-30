tool
extends ProxyTexture

signal texture_changed(new_base_palette, new_swap_palette)
signal palette_updated(new_tex, source_tex_changed)

export var base_palette : PoolColorArray
export var swap_palette : PoolColorArray
export var texture : Texture setget set_texture # The base texture to remap

export var pixel_map : = [] # A map of what pixels belong to position on the palette

class ReferencePoolVector2Array: # Arrays are passed as values, using this prevents us from duplicating arrays with 100's of pixels when setting up the pixel map
	var array : = PoolVector2Array()

	func append(vector : Vector2):
		array.append(vector)

	func _init(first_point : Vector2):
		array.append(first_point)

func set_palette(colors : PoolColorArray):
	if swap_palette.size() != colors.size():
		return

	var img : = base.get_data()
	for i in swap_palette.size():
		if swap_palette[i] == colors[i]:
			continue
		else:
			img.lock()
			for pixel in pixel_map[i]:
				img.set_pixel(pixel.x, pixel.y, swap_palette[i])
			img.unlock()

	swap_palette = colors
	var new_tex : = ImageTexture.new()
	new_tex.create_from_image(img)
	new_tex.flags = texture.flags
	base = new_tex

func update_palette():
	var img : = base.get_data()
	for i in swap_palette.size():
		img.lock()
		for pixel in pixel_map[i]:
			img.set_pixel(pixel.x, pixel.y, swap_palette[i])
		img.unlock()

	var new_tex : = ImageTexture.new()
	new_tex.create_from_image(img)
	new_tex.flags = texture.flags
	base = new_tex

	emit_signal("palette_updated", base, false)

func set_texture(tex : Texture):
	if Engine.get_frames_drawn() == 0: # Prevents palette resetting when the editor or game start
		texture = tex
		return
	if not tex:
		texture = tex
		base = tex
		base_palette = PoolColorArray()
		swap_palette = PoolColorArray()
		pixel_map = []
		emit_signal("texture_changed", base_palette, swap_palette)
		emit_signal("palette_updated", base, true)
		return
	var index : = 0
	var new_palette : = PoolColorArray()
	var new_pixel_map : = []
	var color_index_map : = {} # {color : index}
	var img : = tex.get_data()
	img.lock()
	for x in img.get_width():
		for y in img.get_height():
			var pixel_color : = img.get_pixel(x, y)
			if pixel_color.a == 0:
				continue
			if color_index_map.has(pixel_color):
				new_pixel_map[color_index_map[pixel_color]].append(Vector2(x, y))
			else:
				color_index_map[pixel_color] = index
				new_pixel_map.append(ReferencePoolVector2Array.new(Vector2(x, y)))
				new_palette.append(pixel_color)
				index += 1
	img.unlock()

	base_palette = new_palette
	swap_palette = new_palette
	pixel_map.resize(new_pixel_map.size())
	for i in new_pixel_map.size():
		pixel_map[i] = new_pixel_map[i].array

	texture = tex
	base = tex

	emit_signal("texture_changed", base_palette, swap_palette)
	emit_signal("palette_updated", base, true)