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
@export var tlist:ItemList
@export var meshs:Array[Mesh]
func _ready() -> void:
	OS.request_permissions()
	DirAccess.make_dir_recursive_absolute(OS.get_system_dir(OS.SYSTEM_DIR_PICTURES))
	nodes[17].text = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)+"/"
	nodes[11].grab_focus()
	shader = mesh2d.material.shader
	code.text = shader.code
	code.text_changed.connect(update_shader)
	_window_requsted("Code")
	nodes[3].pressed.connect(_window_requsted.bind("Code"))
	nodes[4].pressed.connect(get_tree().quit)
	nodes[5].pressed.connect(_save_and_quit)
	nodes[7].pressed.connect(save_quit)
	auto_load()
	update_shader()
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
	nodes[13].hide()
func auto_save() -> void:
	DirAccess.make_dir_recursive_absolute(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/Shaders/")
	var  file:FileAccess= FileAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/Shaders/autosave.temp",FileAccess.WRITE)
	file.store_string(code.text)
func auto_load() -> void:
	var  file:FileAccess= FileAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/Shaders/autosave.temp",FileAccess.READ)
	if FileAccess.file_exists(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/Shaders/autosave.temp"):
		code.text = file.get_as_text()
func _window_requsted(window:String) -> void:
	for w in nodes[1].get_children():
		if w.name==window:w.show()
		else: w.hide()
	if window == "Code":
		nodes[8].hide()
	if window == "Load":
		_update_list()
	if window == "Parameters":
		if shader.get_mode()==Shader.MODE_CANVAS_ITEM:
			create_parameters(mesh2d.material)
		else:create_parameters(mesh3d.material_override)
		tlist.clear()
		tlist.update_list()
func _on_exit_fullscreen_pressed() -> void:
	nodes[12].grab_focus()
	nodes[0].show()
	nodes[1].show()
	nodes[2].hide()
func _on_fullscreen_pressed() -> void:
	nodes[2].grab_focus()
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
		mesh2d.show()
		%v3d.hide()
		mesh2d.material.shader = shader
		materals = mesh2d.material
	if shader.get_mode() == Shader.MODE_SPATIAL:
		%v3d.show()
		mesh2d.hide()
		mesh3d.material_override.shader = shader
		materals = mesh3d.material_override
	auto_save()
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
				tick.button_pressed=value if !typeof(value)==0 else false
				tick.focus_mode=Control.FOCUS_NONE
				tick.toggled.connect(bool_changed.bind(nam,mat))
				tick.custom_minimum_size.y=64
				tick.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				lb.text=nam
				nodes[10].add_child(hb)
			TYPE_INT:
				var hb:HBoxContainer=HBoxContainer.new()
				var lb:Label=Label.new()
				var slider:SpinBox=SpinBox.new()
				lb.text = nam
				hb.add_child(lb)
				hb.add_child(slider)
				slider.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				slider.value = value if !typeof(value)==0 else 0
				slider.step = int(hint_str[2]) if hint == 1 and hint_str.size()==3 else 0
				slider.min_value = int(hint_str[0]) if hint == 1 and hint_str.size()!=0 else -1
				slider.max_value = int(hint_str[1]) if hint == 1 and hint_str.size()!=0 else 1
				slider.theme = th
				slider.custom_minimum_size.y = 64
				slider.value_changed.connect(int_changed.bind(nam,mat))
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
				slider.value = float(value) if !typeof(value)==0 else 0.0
				vl.text = str(slider.value).pad_decimals(4)
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
				picker.color = value if !typeof(value)==0 else Color.WHITE_SMOKE
				picker.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				lb.text =nam
				picker.color_changed.connect(color_changed.bind(nam,mat))
				nodes[10].add_child(hb)
			TYPE_OBJECT:
				var hb:HBoxContainer=HBoxContainer.new()
				var lb:Label=Label.new()
				var button:Button=Button.new()
				lb.text=nam
				button.text="Load"
				button.custom_minimum_size.y=64
				button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				hb.add_child(lb)
				hb.add_child(button)
				button.pressed.connect(_window_requsted.bind("LoadTexture"))
				nodes[10].add_child(hb)
				if tlist.item_selected.get_connections().size()==0:
					tlist.item_selected.connect(_on_texture_selected.bind(nam,mat))
func bool_changed(bol:bool,nam:String,mat:ShaderMaterial):
	mat.set_shader_parameter(nam,bol)
func float_changed(val:float,nam:String,mat:ShaderMaterial,vl:Label):
	vl.text = str(val).pad_decimals(4)
	mat.set_shader_parameter(nam,val)
func int_changed(val:float,nam:String,mat:ShaderMaterial):
	mat.set_shader_parameter(nam,val)
func color_changed(col:Color,nam:String,mat:ShaderMaterial):mat.set_shader_parameter(nam,col)
func _font_size_changed(value: float) -> void:
	code.add_theme_font_size_override("font_size",int(value))
func _on_wrap_toggled(toggled: bool) -> void:
	code.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY if toggled else TextEdit.LINE_WRAPPING_NONE
func _on_save_pressed() -> void:
	nodes[13].show()
	nodes[13].get_child(0).get_child(1).pressed.connect(manual_save)
func manual_save():_save(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/Shaders/",nodes[14].text)
func _on_export_image() -> void:
	subview.stretch=false
	view.size = Vector2(nodes[15].value,nodes[16].value)
	await RenderingServer.frame_post_draw
	var i:Image=view.get_texture().get_image()
	i.save_png(OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)+"/"+str(hash(randi()))+".png")
	subview.stretch=true
func _on_transparent_toggled(toggled: bool) -> void:view.transparent_bg=toggled
func _on_fps_toggled(toggled: bool) -> void:$fps.visible = toggled
func _on_bg_color_changed(col: Color) -> void:color=col
func _on_texture_selected(index: int,nam:String,mat:ShaderMaterial) -> void:
	mat.set_shader_parameter(nam,ImageTexture.create_from_image(Image.load_from_file(nodes[17].text+tlist.get_item_text(index))))
func _on_mesh_selected(index: int) -> void:mesh3d.mesh=meshs[index]
func _on_scale_item_selected(index: int) -> void:subview.stretch_shrink=%scale.get_item_id(index)
func _on_texture_list_pressed() -> void:
	_window_requsted("LoadTexture")
	tlist.clear()
	tlist.update_list()

func _on_new_tex_pressed() -> void:
	$noisegen.show()
