extends Node3D
@export_range(0.0,1.0,0.001) var sensitivity:float = 0.1
@onready var cam:Camera3D=$cam
func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if not event.is_pressed():
			rotation_degrees.x -= event.relative.y*sensitivity
			rotation_degrees.y -= event.relative.x*sensitivity


func _on_subview_gui_input(event: InputEvent) -> void:
	cam.position.z+= Input.get_axis("zoomup","zoomdown")*sensitivity
	if event is InputEventMagnifyGesture:
		if event.factor>1.0:
			cam.position.z-= sensitivity*0.5
		if event.factor<1.0:
			cam.position.z+= sensitivity*0.5
