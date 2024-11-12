extends ItemList
var path :String=OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
func _ready() -> void:
	for p in DirAccess.get_files_at(path):
		if p.get_extension() == "png" or "jpg":
			var i = Image.load_from_file(path+"/"+p)
			i.resize(128,128)
			var t =ImageTexture.create_from_image(i)
			add_item(p,t)


func _on_path_changed(new_text: String) -> void:
	path = new_text
