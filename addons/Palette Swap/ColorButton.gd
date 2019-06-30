extends Button

var color : Color setget set_color
var swap : ColorPickerButton

func _init(base_color : Color, swap_node : ColorPickerButton):
	flat = true
	color = base_color
	swap = swap_node
	connect_signals(swap_node)

func _draw():
	var normal : = get_stylebox("normal")
	draw_rect(Rect2(normal.get_offset(), rect_size - normal.get_minimum_size()), color, true)

func set_color(new_color : Color):
	disconnect_signals(swap)
	color = new_color
	connect_signals(swap)
	update()

func connect_signals(swap_node : ColorPickerButton):
	connect("pressed", swap_node, "set_pick_color", [color])
	connect("pressed", swap_node, "emit_signal", ["color_changed", color])

func disconnect_signals(swap_node : ColorPickerButton):
	disconnect("pressed", swap, "set_pick_color")
	disconnect("pressed", swap, "emit_signal")