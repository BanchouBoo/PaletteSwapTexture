extends HBoxContainer

const TexturePreviewRect : = preload("TexturePreviewRect.gd")

var preview_rect : TexturePreviewRect

var frame_info_container : = VBoxContainer.new()
var h_frame_counter : = SpinBox.new()
var v_frame_counter : = SpinBox.new()
var current_frame_counter : = SpinBox.new()

func _init(tex : Texture):
	connect("resized", self, "on_resized")

	preview_rect = TexturePreviewRect.new(tex)
	add_child(preview_rect)

	add_child(frame_info_container)
	var h_frame_row : = HBoxContainer.new()
	var v_frame_row : = HBoxContainer.new()
	var current_frame_row : = HBoxContainer.new()

	var h_frame_label : = Label.new()
	h_frame_label.text = "H Frames"
	h_frame_counter.value = preview_rect.h_frames
	h_frame_counter.min_value = 1
	h_frame_counter.connect("value_changed", self, "on_h_frames_updated")
	h_frame_label.size_flags_horizontal = SIZE_EXPAND_FILL
	h_frame_counter.size_flags_horizontal = SIZE_EXPAND_FILL
	h_frame_row.add_child(h_frame_label)
	h_frame_row.add_child(h_frame_counter)

	var v_frame_label : = Label.new()
	v_frame_label.text = "V Frames"
	v_frame_counter.value = preview_rect.v_frames
	v_frame_counter.min_value = 1
	v_frame_counter.connect("value_changed", self, "on_v_frames_updated")
	v_frame_label.size_flags_horizontal = SIZE_EXPAND_FILL
	v_frame_counter.size_flags_horizontal = SIZE_EXPAND_FILL
	v_frame_row.add_child(v_frame_label)
	v_frame_row.add_child(v_frame_counter)

	var current_frame_label : = Label.new()
	current_frame_label.text = "Frame"
	current_frame_counter.value = preview_rect.current_frame
	current_frame_counter.max_value = preview_rect.h_frames * preview_rect.v_frames
	current_frame_counter.connect("value_changed", self, "on_current_frame_updated")
	current_frame_label.size_flags_horizontal = SIZE_EXPAND_FILL
	current_frame_counter.size_flags_horizontal = SIZE_EXPAND_FILL
	current_frame_row.add_child(current_frame_label)
	current_frame_row.add_child(current_frame_counter)

	frame_info_container.add_child(h_frame_row)
	frame_info_container.add_child(v_frame_row)
	frame_info_container.add_child(current_frame_row)

func on_h_frames_updated(value : int):
	preview_rect.h_frames = value
	current_frame_counter.max_value = preview_rect.h_frames * preview_rect.v_frames

func on_v_frames_updated(value : int):
	preview_rect.v_frames = value
	current_frame_counter.max_value = preview_rect.h_frames * preview_rect.v_frames

func on_current_frame_updated(value : int):
	preview_rect.current_frame = value

func on_palette_updated(new_tex : Texture, source_tex_changed : bool):
	if source_tex_changed:
		preview_rect.h_frames = 1
		h_frame_counter.value = 1
		preview_rect.v_frames = 1
		v_frame_counter.value = 1
		preview_rect.current_frame = 0
		current_frame_counter.value = 0
	preview_rect.texture = new_tex

func on_resized():
	disconnect("resized", self, "on_resized")
	rect_position.x -= rect_size.x
	rect_size.x *= 2
	connect("resized", self, "on_resized")