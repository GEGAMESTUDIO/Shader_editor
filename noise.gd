extends Panel
@export var params:VBoxContainer
@export var tex:TextureRect
@export var noise:NoiseTexture2D
@export var noiselib:FastNoiseLite
@export var split:SplitContainer

func _ready() -> void:
	OS.request_permissions()
	for t in noise.get_property_list():
		var nam = t.name
		var type = t.type
		var hint = t.hint_string.split(",")
		var value = noise.get(nam)
		match type:
			TYPE_INT:
				var hb:HBoxContainer=HBoxContainer.new()
				var lb:Label=Label.new()
				var sl:SpinBox=SpinBox.new()
				sl.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				sl.min_value=int(hint[0])
				sl.max_value=int(hint[1])
				sl.allow_greater=true
				sl.value= value if typeof(value)!=0 else 1024
				sl.step=int(hint[2])
				sl.custom_minimum_size.y=32
				sl.value_changed.connect(int_changed.bind(nam,noise))
				lb.text=nam
				hb.add_child(lb)
				hb.add_child(sl)
				params.add_child(hb)
			TYPE_BOOL:
				var ck:CheckButton=CheckButton.new()
				ck.custom_minimum_size.y=32
				ck.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				ck.text=nam
				ck.button_pressed=bool(value)
				ck.toggled.connect(bool_changed.bind(nam,noise))
				params.add_child(ck)
				if nam=="resource_local_to_scene":ck.hide()
				if nam=="generate_mipmaps":ck.hide()
	for l in noiselib.get_property_list():
		var nam = l.name
		var type = l.type
		var hint = l.hint
		var hintstr = l.hint_string.split(",")
		var value = noiselib.get(nam)
		match type:
			TYPE_INT:
				if hint==PROPERTY_HINT_ENUM:#for types
					var thb:HBoxContainer=HBoxContainer.new()
					var tlb:Label=Label.new()
					var tsl:OptionButton=OptionButton.new()
					tsl.size_flags_horizontal=Control.SIZE_EXPAND_FILL
					tsl.custom_minimum_size.y=32
					for n in hintstr:
						tsl.add_item(n)
					tsl.item_selected.connect(type_changed.bind(nam,noiselib))
					tlb.text=nam
					tsl.selected=int(value)
					thb.add_child(tlb)
					thb.add_child(tsl)
					params.add_child(thb)
				else:
					var hb:HBoxContainer=HBoxContainer.new()
					var lb:Label=Label.new()
					var sl:SpinBox=SpinBox.new()
					sl.step=1
					sl.value=int(value)
					sl.size_flags_horizontal=Control.SIZE_EXPAND_FILL
					sl.custom_minimum_size.y=32
					sl.value_changed.connect(int_changed.bind(nam,noiselib))
					lb.text=nam
					hb.add_child(lb)
					hb.add_child(sl)
					params.add_child(hb)
			TYPE_FLOAT:
				var hb:HBoxContainer=HBoxContainer.new()
				var lb:Label=Label.new()
				var sl:SpinBox=SpinBox.new()
				sl.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				sl.allow_greater=true
				sl.value= value if typeof(value)!=0 else 0.5
				sl.step=float(hintstr[2]) if hintstr.size()!=1 else 0.001
				sl.custom_minimum_size.y=32
				sl.value_changed.connect(float_changed.bind(nam,noiselib))
				lb.text=nam
				hb.add_child(lb)
				hb.add_child(sl)
				params.add_child(hb)
			TYPE_BOOL:
				var ck:CheckButton=CheckButton.new()
				ck.custom_minimum_size.y=32
				ck.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				ck.text=nam
				ck.button_pressed=bool(value)
				ck.toggled.connect(bool_changed.bind(nam,noiselib))
				params.add_child(ck)
				if nam=="resource_local_to_scene":ck.hide()
	print(noiselib.get_property_list())

func int_changed(val:int,nam:String,n):
	n.set(nam,val)
func bool_changed(t:bool,nam:String,n):
	n.set(nam,t)
func float_changed(val:float,nam:String,n):
	n.set(nam,val)
func type_changed(id:int,nam:String,n):
	n.set(nam,id)


func _on_save_pressed() -> void:
	tex.texture.get_image().save_png(OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)+"/"+str(hash(randi()))+".png")
	_on_close_pressed()
func _on_close_pressed() -> void:
	$"../../..".hide()
