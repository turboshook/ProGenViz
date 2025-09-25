extends FloorGenerator

func _init() -> void:
	_default_parameters = {}
	_info_text = "\
		Info text here!\
	"

@warning_ignore("unused_parameter")
func generate(parameters: Dictionary) -> void:
	_gen_data = {}
