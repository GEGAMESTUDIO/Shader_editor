extends CodeEdit
@export var keywords:PackedStringArray
@export var consts:PackedStringArray
@export var vars:PackedStringArray
@export var funcs:PackedStringArray
@export var th:Theme
var m:PopupMenu=get_menu()
func _ready() -> void:
	get_v_scroll_bar().theme=th
	get_h_scroll_bar().theme=th
	m.item_count = m.get_item_index(MENU_REDO) + 1
	m.position=get_viewport().size/2
	text_changed.connect(update)
	var h:CodeHighlighter=syntax_highlighter
	h.add_color_region("//","",Color.DIM_GRAY)
	for k in keywords:
		h.add_keyword_color(k,Color(1.0,0.43,0.51))

func update() -> void:
	for c in consts:
		add_code_completion_option(CodeEdit.KIND_CONSTANT,c,c,Color.WHEAT,null,null,0)
	for v in vars:
		add_code_completion_option(CodeEdit.KIND_VARIABLE,v,v)
	for f in funcs:
		add_code_completion_option(CodeEdit.KIND_FUNCTION,f+"()",f+"()",Color.CORNFLOWER_BLUE,null,null,0)
	update_code_completion_options(true)
