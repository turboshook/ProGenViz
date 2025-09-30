extends OptionButton
class_name AlgorithmSelectionButton

signal algorithm_selected(category: String, generator_name: String) 

var _algorithm_dictionary: Dictionary
var _popup_menu: PopupMenu
var _current_index: int = 0

func _ready() -> void:
	mouse_entered.connect(func(): if not is_pressed(): AudioManager.play_sound("hover"))
	item_selected.connect(_on_item_selected)

func _process(_delta: float) -> void:
	if not _popup_menu: return
	if _popup_menu.get_focused_item() == _current_index: return
	_current_index = _popup_menu.get_focused_item()
	AudioManager.play_sound("hover")

func initialize(algorithm_dictionary: Dictionary) -> void:
	clear()
	_algorithm_dictionary = algorithm_dictionary
	for category: String in _algorithm_dictionary.keys():
		add_separator(category)
		for generator_name: String in _algorithm_dictionary[category].keys():
			add_item(generator_name)
	_popup_menu = get_popup()

func _on_item_selected(index: int) -> void:
	var generator_name: String = get_item_text(index)
	for category: String in _algorithm_dictionary.keys():
		if not _algorithm_dictionary[category].has(generator_name): continue
		algorithm_selected.emit(category, generator_name)
