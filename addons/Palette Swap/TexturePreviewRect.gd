extends Control

const RECT_HEIGHT : = 128

var texture : Texture setget set_texture
var h_frames : = 1 setget set_h_frames
var v_frames : = 1 setget set_v_frames
var current_frame : = 0 setget set_current_frame
var ratio : float

func _init(tex : Texture):
	set_texture(tex)
	size_flags_horizontal = SIZE_EXPAND_FILL
	rect_min_size.y = RECT_HEIGHT

func _draw():
	if texture:
		var size : = Vector2(RECT_HEIGHT * ratio, RECT_HEIGHT)
		if h_frames * v_frames == 1:
			draw_texture_rect(texture, Rect2(Vector2(), size), false)
		else:
			var frame : int = min(current_frame, (h_frames * v_frames) - 1)
			var region_size : = Vector2(
				texture.get_width() / h_frames,
				texture.get_height() / v_frames
			)
			var region_position : = Vector2(frame % h_frames, frame / h_frames) * region_size
			draw_texture_rect_region(texture, Rect2(Vector2(), size), Rect2(region_position, region_size))

func set_texture(new_tex : Texture):
	texture = new_tex
	ratio = float(texture.get_width()) / float(texture.get_height())
	update()

func set_h_frames(count : int):
	h_frames = max(count, 1)
	update()

func set_v_frames(count : int):
	v_frames = max(count, 1)
	update()

func set_current_frame(frame : int):
	current_frame = min(frame, (h_frames * v_frames) - 1)
	update()