extends ItemList
var path:String = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)+"/"

func update_list(spath:String=path):
	for t in DirAccess.get_files_at(spath):
		if t.get_extension() == 'png' or 'jepg':
			var i:Image=Image.load_from_file(spath+t)
			i.resize(128,128)
			add_item(t,ImageTexture.create_from_image(i))

func _on_path_changed(ntext:String):
	path = ntext
