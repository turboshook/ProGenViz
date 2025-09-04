extends GeneratorParameterInterface

@onready var floor_dimension_x: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/FloorProperties/FloorSize/HBoxContainer/FloorDimensionX
@onready var floor_dimension_y: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/FloorProperties/FloorSize/HBoxContainer2/FloorDimensionY
#@onready var room_count_min: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/FloorProperties/RoomCount/VBoxContainer/HBoxContainer/RoomCountMin
@onready var room_count_max: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/FloorProperties/RoomCount/VBoxContainer/HBoxContainer2/RoomCountMax
@onready var room_size_min_x: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/RoomProperties/RoomSizeMin/HBoxContainer/RoomSizeMinX
@onready var room_size_min_y: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/RoomProperties/RoomSizeMin/HBoxContainer2/RoomSizeMinY
@onready var room_size_max_x: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/RoomProperties/RoomSizeMax/HBoxContainer/RoomSizeMaxX
@onready var room_size_max_y: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/RoomProperties/RoomSizeMax/HBoxContainer2/RoomSizeMaxY
@onready var room_padding_x: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/MiscProperties/RoomPadding/VBoxContainer/HBoxContainer/RoomPaddingX
@onready var room_padding_y: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/MiscProperties/RoomPadding/VBoxContainer/HBoxContainer2/RoomPaddingY
@onready var retries: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/MiscProperties/Retries/Retries

func get_parameters() -> Dictionary:
	return {
		"floor_size": Vector2i(
			int(floor_dimension_x.get_line_edit().text), 
			int(floor_dimension_y.get_line_edit().text)
		),
		#"min_room_count": int(room_count_min.get_line_edit().text),
		"max_room_count": int(room_count_max.get_line_edit().text),
		"min_room_size": Vector2i(
			int(room_size_min_x.get_line_edit().text),
			int(room_size_min_y.get_line_edit().text)
		),
		"max_room_size": Vector2i(
			int(room_size_max_x.get_line_edit().text),
			int(room_size_max_y.get_line_edit().text)
		),
		"room_padding": Vector2i(
			int(room_padding_x.get_line_edit().text),
			int(room_padding_y.get_line_edit().text)
		),
		"retry_threshold": int(retries.get_line_edit().text)
	}
