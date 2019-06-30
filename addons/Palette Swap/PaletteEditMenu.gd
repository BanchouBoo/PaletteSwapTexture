extends VBoxContainer

signal palette_changed(new_palette)

const ColorButton : = preload("ColorButton.gd")

const PALETTE_SELECTOR_HEIGHT : = 26
const MAX_VISIBLE_PALETTE_SELECTORS : = 16

var base_palette : = PoolColorArray()
var swap_palette : = PoolColorArray()

var expander : = Button.new()
var open : = false

var scrollbox : = ScrollContainer.new()
var hbox : = HBoxContainer.new()

var orig_color_container : = VBoxContainer.new()
var swap_color_container : = VBoxContainer.new()

func _init():
	size_flags_horizontal = SIZE_EXPAND_FILL

	expander.text = "Open Palette Editor"
	add_child(expander)
	expander.connect("pressed", self, "on_expander_pressed")

	scrollbox.rect_min_size.y = (PALETTE_SELECTOR_HEIGHT * MAX_VISIBLE_PALETTE_SELECTORS) + (get_constant("separation") * (MAX_VISIBLE_PALETTE_SELECTORS - 1))
	add_child(scrollbox)
	scrollbox.hide()

	hbox.size_flags_horizontal = SIZE_EXPAND_FILL
	scrollbox.add_child(hbox)
#	hbox.hide()

	orig_color_container.size_flags_horizontal = SIZE_EXPAND_FILL
	swap_color_container.size_flags_horizontal = SIZE_EXPAND_FILL
	hbox.add_child(orig_color_container)
	hbox.add_child(swap_color_container)

func on_expander_pressed():
	if open:
		scrollbox.hide()
		expander.text = "Open Palette Editor"
	else:
		scrollbox.show()
		expander.text = "Close Palette Editor"
	open = !open

func update_palette(new_base_palette, new_swap_palette : PoolColorArray):
	var current_palette_size : = swap_palette.size()
	var new_palette_size : = new_swap_palette.size()

	if current_palette_size > new_palette_size:
		for i in range(new_palette_size):
			update_color(i, new_base_palette[i], new_swap_palette[i])

		for i in range(new_palette_size, current_palette_size):
			orig_color_container.get_child(i).queue_free()
			swap_color_container.get_child(i).queue_free()
	elif current_palette_size < new_palette_size:
		for i in range(current_palette_size):
			update_color(i, new_base_palette[i], new_swap_palette[i])
		
		for i in range(current_palette_size, new_palette_size):
			add_color(new_base_palette[i], new_swap_palette[i])
	else:
		for i in range(current_palette_size):
			update_color(i, new_base_palette[i], new_swap_palette[i])

	var max_palette_selectors : = min(new_palette_size, MAX_VISIBLE_PALETTE_SELECTORS)
	scrollbox.rect_min_size.y = (PALETTE_SELECTOR_HEIGHT * max_palette_selectors) + (get_constant("separation") * max((max_palette_selectors - 1), 0))

	swap_palette = new_swap_palette

func add_color(base_color, swap_color : Color):
	var color_picker : = ColorPickerButton.new()
	color_picker.color = swap_color
	color_picker.flat = true
	swap_color_container.add_child(color_picker)
	color_picker.connect("color_changed", self, "on_color_changed", [color_picker.get_index()])

	var color_button : = ColorButton.new(base_color, color_picker)
	orig_color_container.add_child(color_button)

func update_color(index : int, new_base_color : Color, new_swap_color : Color):
	var orig_button : = orig_color_container.get_child(index)
	var swap_button : = swap_color_container.get_child(index)

	swap_button.disconnect("color_changed", self, "on_color_changed")
	swap_button.connect("color_changed", self, "on_color_changed", [index])

	orig_button.color = new_base_color
	swap_button.color = new_swap_color

func on_color_changed(color : Color, index : int):
	swap_palette[index] = color
	emit_signal("palette_changed", swap_palette)