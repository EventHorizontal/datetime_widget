extends Control

# Digital Clock
@export var time_label: Label
@export var seconds_label: Label
@export var meridiem_label: Label
@export var date_label: Label
@export var day_label: Label

# Analog Display
@export var analog_display_canvas_group : Node2D
@export var hour_hand: Line2D
@export var minute_hand: Line2D
@export var second_hand: Line2D

var window_size_step_size := Vector2i(54, 10)
var is_window_being_dragged := false
var window_drag_mouse_offset : Vector2i = Vector2i.ZERO

# Locking
@export var locked_icon: TextureRect
var locked = true

const MAX_HOURS_12_HOUR_CLOCK := 12
const focus_colour := Color("#EE9950")

const month_names = {
	1: "Jan",
	2: "Feb",
	3: "Mar",
	4: "Apr",
	5: "May",
	6: "Jun",
	7: "Jul",
	8: "Aug",
	9: "Sep",
	10: "Oct",
	11: "Nov",
	12: "Dec",
}

const weekday_names = {
	0: "Sun",
	1: "Mon",
	2: "Tue",
	3: "Wed",
	4: "Thu",
	5: "Fri",
	6: "Sat",
}

# Positioning
enum horizontal_positions {
	LEFT,
	CENTRE,
	RIGHT,
}

enum vertical_positions {
	TOP,
	CENTRE,
	BOTTOM,
}

const PADDING := 32
var current_position := {
	"horizontal": horizontal_positions.CENTRE,
	"vertical": vertical_positions.TOP
}


func _ready() -> void:
	@warning_ignore("INTEGER_DIVISION")
	#DisplayServer.window_set_size(Vector2i((DisplayServer.window_get_size().y * 54)/ 10, DisplayServer.window_get_size().y))
	#DisplayServer.window_set_size(DisplayServer.window_get_size() - 3 * window_size_step_size)
	@warning_ignore("INTEGER_DIVISION")
	set_horizontal_window_position(horizontal_positions.CENTRE)
	set_vertical_window_position(vertical_positions.TOP)
	#self.modulate.a8 = 192
	#analog_display.modulate.a8 = 192 
	set_process(false)
	get_tree().set_auto_accept_quit(false)

func _process(_delta) -> void:
	var date_time = Time.get_datetime_dict_from_system()
	var weekday: int = Time.get_date_dict_from_system()["weekday"]
	var weekday_name: String = weekday_names[weekday]
	
	hour_hand.rotation = ((date_time.hour % 12) as float / 12.0) * TAU
	minute_hand.rotation = (date_time.minute as float / 60.0) * TAU 
	second_hand.rotation = (date_time.second as float / 60.0) * TAU
	
	if date_time.hour < MAX_HOURS_12_HOUR_CLOCK:
		var hour = date_time.hour if date_time.hour > 0 else 12
		time_label.text =  "%02d" % hour + ":" +  "%02d" % date_time.minute
		meridiem_label.text = "AM"
	else:
		var hour = date_time.hour - 12 if date_time.hour - 12 > 0 else 12
		time_label.text =  "%02d" % hour + ":" +  "%02d" % date_time.minute
		meridiem_label.text = "PM"
	seconds_label.text = "%02d" % date_time.second
	date_label.text =  get_ordinal_number_as_string(date_time.day) + " " + month_names[date_time.month] + " " + String.num_int64(date_time.year)
	day_label.text = weekday_name
	set_process(false)

func _notification(what):
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		self.modulate = Color(focus_colour.r, focus_colour.g, focus_colour.b, self.modulate.a)
		analog_display_canvas_group.modulate = Color(focus_colour.r, focus_colour.g, focus_colour.b, analog_display_canvas_group.modulate.a)
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		self.modulate = Color(1, 1, 1, self.modulate.a)
		analog_display_canvas_group.modulate = Color(1, 1, 1, analog_display_canvas_group.modulate.a)
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		if self.locked:
			return
		else:
			get_tree().quit()


func _input(event: InputEvent):
	if not Input.is_action_pressed("ui_click"):
		ProjectSettings.set("application/run/low_processor_mode", true) 
	
	if event.is_action_released("ui_quit") and not self.locked:
		get_tree().quit()
	elif Input.is_action_just_pressed("size_up"):
		DisplayServer.window_set_size(DisplayServer.window_get_size() + window_size_step_size)
		set_horizontal_window_position(self.current_position["horizontal"])
		set_vertical_window_position(self.current_position["vertical"])
	elif Input.is_action_just_pressed("size_down"):
		DisplayServer.window_set_size(DisplayServer.window_get_size() - window_size_step_size)
		set_horizontal_window_position(self.current_position["horizontal"])
		set_vertical_window_position(self.current_position["vertical"])
	elif Input.is_action_just_pressed("toggle_border"):
		print("Borderless: " + str(ProjectSettings.get("display/window/size/borderless")))
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, not DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS))
		print("Borderless: " + str(ProjectSettings.get("display/window/size/borderless")))
	elif Input.is_action_just_pressed("lock"):
		self.locked = !self.locked
		locked_icon.visible = not locked_icon.visible
	elif Input.is_action_just_pressed("opacity_up"):
		for node in get_tree().get_nodes_in_group("opacity"):
			node.modulate.a = minf(node.modulate.a + 0.1, 1.0)
	elif Input.is_action_just_pressed("opacity_down"):
		for node in get_tree().get_nodes_in_group("opacity"):
			node.modulate.a = maxf(node.modulate.a - 0.1, 0.1)
	elif Input.is_action_just_pressed("move_left"):
		match self.current_position["horizontal"]:
			horizontal_positions.CENTRE:
				self.current_position["horizontal"] = horizontal_positions.LEFT
				set_horizontal_window_position(horizontal_positions.LEFT)
			horizontal_positions.RIGHT:
				self.current_position["horizontal"] = horizontal_positions.CENTRE
				set_horizontal_window_position(horizontal_positions.CENTRE)
	elif Input.is_action_just_pressed("move_right"):
		match self.current_position["horizontal"]:
			horizontal_positions.LEFT:
				self.current_position["horizontal"] = horizontal_positions.CENTRE
				set_horizontal_window_position(horizontal_positions.CENTRE)
			horizontal_positions.CENTRE:
				self.current_position["horizontal"] = horizontal_positions.RIGHT
				set_horizontal_window_position(horizontal_positions.RIGHT)
	elif Input.is_action_just_pressed("move_up"):
		match self.current_position["vertical"]:
			vertical_positions.CENTRE:
				self.current_position["vertical"] = vertical_positions.TOP
				set_vertical_window_position(vertical_positions.TOP)
			vertical_positions.BOTTOM:
				self.current_position["vertical"] = vertical_positions.CENTRE
				set_vertical_window_position(vertical_positions.CENTRE)
	elif Input.is_action_just_pressed("move_down"):
		match self.current_position["vertical"]:
			vertical_positions.TOP:
				self.current_position["vertical"] = vertical_positions.CENTRE
				set_vertical_window_position(vertical_positions.CENTRE)
			vertical_positions.CENTRE:
				self.current_position["vertical"] = vertical_positions.BOTTOM
				set_vertical_window_position(vertical_positions.BOTTOM)
	elif Input.is_action_just_pressed("ui_click"):
		ProjectSettings.set("application/run/low_processor_mode", false)
		print_debug("Exiting low processor mode")
		is_window_being_dragged = true
		window_drag_mouse_offset = get_global_mouse_position()
	elif Input.is_action_pressed(&"ui_click") and is_window_being_dragged:
		DisplayServer.window_set_position(DisplayServer.mouse_get_position() - window_drag_mouse_offset)
	elif Input.is_action_just_released(&"ui_click"):
		print_debug("Entering low processor mode")
		ProjectSettings.set("application/run/low_processor_mode", true)
		is_window_being_dragged = false
		window_drag_mouse_offset = Vector2i.ZERO

func set_horizontal_window_position(pos: horizontal_positions) -> void:
	var screen_size := DisplayServer.screen_get_size()
	var window_size := DisplayServer.window_get_size()
	match pos:
		horizontal_positions.LEFT:
			print_debug("horizontally left")
			DisplayServer.window_set_position(Vector2i(PADDING, DisplayServer.window_get_position().y))
		horizontal_positions.CENTRE:
			print_debug("horizontally centre")
			DisplayServer.window_set_position(Vector2i(screen_size.x / 2 - window_size.x / 2, DisplayServer.window_get_position().y))
		horizontal_positions.RIGHT:
			print_debug("horizontally right")
			DisplayServer.window_set_position(Vector2i(screen_size.x - window_size.x - PADDING, DisplayServer.window_get_position().y))

func set_vertical_window_position(pos: vertical_positions) -> void:
	var screen_size := DisplayServer.screen_get_size()
	var window_size := DisplayServer.window_get_size()
	match pos:
		vertical_positions.TOP:
			print_debug("vertically top")
			DisplayServer.window_set_position(Vector2i(DisplayServer.window_get_position().x, PADDING))
		vertical_positions.CENTRE:
			print_debug("vertically centre")
			DisplayServer.window_set_position(Vector2i(DisplayServer.window_get_position().x, screen_size.y / 2 - window_size.y / 2))
		vertical_positions.BOTTOM:
			print_debug("vertically bottom")
			DisplayServer.window_set_position(Vector2i(DisplayServer.window_get_position().x, screen_size.y - window_size.y - PADDING))

func get_ordinal_number_as_string(number: int) -> String:
	match number:
		1:
			return "1st"
		2:
			return "2nd"
		3:
			return "3rd"
		_:
			return String.num_int64(number) + "th"

func _on_timer_timeout() -> void:
	set_process(true)
