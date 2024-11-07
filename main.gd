extends ColorRect
@export var nodes:Array[Control]
@export var code:CodeEdit
var shader:Shader=Shader.new()
var materals:ShaderMaterial
@export var subview:SubViewportContainer
@export var view:SubViewport
@export var mesh2d:ColorRect
@export var mesh3d:MeshInstance3D
@export var th:Theme
func _ready() -> void:
	shader = mesh2d.material.shader
	code.text = shader.code
	code.text_changed.connect(update_shader)
	_window_requsted("Code")
	nodes[3].pressed.connect(_window_requsted.bind("Code"))
	nodes[4].pressed.connect(get_tree().quit)
	nodes[5].pressed.connect(_save_and_quit)
	nodes[7].pressed.connect(save_quit)

func _save_and_quit() -> void:nodes[8].show()
func save_quit() -> void:
	var path:String= OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/Shaders/"
	var fname:String=nodes[6].text
	if fname=="":fname = str(hash(randi()))
	_save(path,fname)
	get_tree().quit()

func _save(path:String,fname:String) -> void:
	DirAccess.make_dir_recursive_absolute(path)
	var file:FileAccess=FileAccess.open(path+fname+".gdshader",FileAccess.WRITE)
	file.store_string(code.text)
	file.close()

func _window_requsted(window:String) -> void:
	for w in nodes[1].get_children():
		if w.name==window:w.show()
		else: w.hide()
	if window == "Code":
		nodes[8].hide()
	if window == "Load":
		_update_list()
	if window == "Parameters":
		create_parameters(mesh2d.material)
		$fps2.text = str(shader.get_shader_uniform_list())

func _on_exit_fullscreen_pressed() -> void:
	nodes[0].show()
	nodes[1].show()
	nodes[2].hide()

func _on_fullscreen_pressed() -> void:
	nodes[0].hide()
	nodes[1].hide()
	nodes[2].show()
func _process(_delta: float) -> void:
	$fps.text = "FPS : "+str(Engine.get_frames_per_second())
func _update_list():
	var path:String=OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/Shaders/"
	var epath:String="res://Examples/"
	for c in nodes[9].get_children():
		c.queue_free()
	for n in DirAccess.get_files_at(epath):
		var btn:Button=Button.new()
		btn.text = n
		btn.pressed.connect(current_selection_ex.bind(btn))
		nodes[9].add_child(btn)
	for n in DirAccess.get_files_at(path):
		var btn:Button=Button.new()
		btn.text = n
		btn.pressed.connect(current_selection.bind(btn))
		nodes[9].add_child(btn)

func current_selection(btn:Button):
	var file:FileAccess=FileAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/Shaders/"+btn.text,FileAccess.READ)
	code.text = file.get_as_text()
	shader.code = file.get_as_text()
	update_shader()
func current_selection_ex(btn:Button):
	var file:FileAccess=FileAccess.open("res://Examples/"+btn.text,FileAccess.READ)
	code.text = file.get_as_text()
	shader.code = file.get_as_text()
	update_shader()

func update_shader() -> void:
	shader.code = code.text
	if shader.get_mode() == Shader.MODE_CANVAS_ITEM:
		mesh2d.material.shader = shader
		materals = mesh2d.material
func create_parameters(mat:ShaderMaterial)-> void:
	for c in nodes[10].get_children():
		c.queue_free()
	var uniforms:Array=mat.shader.get_shader_uniform_list()
	for u in uniforms:
		var nam = u.name
		var type = u.type
		var value = mat.get_shader_parameter(nam)
		var hint:int = u.hint
		var hint_str = u.hint_string.split(",")
		match type:
			TYPE_NIL:
				return
			TYPE_BOOL:
				var hb:HBoxContainer=HBoxContainer.new()
				var lb:Label=Label.new()
				var tick:CheckButton=CheckButton.new()
				hb.add_child(lb)
				hb.add_child(tick)
				tick.focus_mode=Control.FOCUS_NONE
				tick.toggled.connect(bool_changed.bind(nam,mat))
				tick.custom_minimum_size.y=64
				tick.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				lb.text=nam
				nodes[10].add_child(hb)
			TYPE_FLOAT:
				var hb:HBoxContainer=HBoxContainer.new()
				var lb:Label=Label.new()
				var vl:Label=Label.new()
				var slider:HSlider=HSlider.new()
				lb.text = nam
				hb.add_child(lb)
				hb.add_child(vl)
				hb.add_child(slider)
				slider.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				slider.value = 0.5
				vl.text = str(slider.value)
				slider.step = float(hint_str[2]) if hint == 1 and hint_str.size()==3 else 0.1
				slider.min_value = float(hint_str[0]) if hint == 1 and hint_str.size()!=0 else -1.0
				slider.max_value = float(hint_str[1]) if hint == 1 and hint_str.size()!=0 else 1.0
				slider.theme = th
				slider.custom_minimum_size.y = 64
				slider.value_changed.connect(float_changed.bind(nam,mat,vl))
				nodes[10].add_child(hb)
			TYPE_COLOR:
				var hb:HBoxContainer=HBoxContainer.new()
				var lb:Label=Label.new()
				var picker:ColorPickerButton=ColorPickerButton.new()
				picker.color=Color.BLACK
				picker.custom_minimum_size.y = 64
				hb.add_child(lb)
				hb.add_child(picker)
				picker.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				lb.text =nam
				picker.color_changed.connect(color_changed.bind(nam,mat))
				nodes[10].add_child(hb)
			TYPE_OBJECT:
				var hb:HBoxContainer=HBoxContainer.new()
				var lb:Label=Label.new()
				var pt:FileDialog=FileDialog.new()
				pt.file_mode=FileDialog.FILE_MODE_OPEN_FILE
				pt.access=FileDialog.ACCESS_FILESYSTEM
				var button:Button=Button.new()
				lb.text=nam
				button.text="Load"
				button.custom_minimum_size.y=64
				button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				hb.add_child(lb)
				hb.add_child(button)
				nodes[10].add_child(hb)
func bool_changed(bol:bool,nam:String,mat:ShaderMaterial):
	mat.set_shader_parameter(nam,bol)
func float_changed(val:float,nam:String,mat:ShaderMaterial,vl:Label):
	vl.text = str(val).pad_decimals(4)
	mat.set_shader_parameter(nam,val)
func color_changed(col:Color,nam:String,mat:ShaderMaterial):
	mat.set_shader_parameter(nam,col)
