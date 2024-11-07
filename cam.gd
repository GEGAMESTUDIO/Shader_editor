extends Node3D
@export_range(0.0,1.0,0.001) var sensitivity:float = 0.1
func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if not event.is_pressed():
			rotation_degrees.x -= event.relative.y*sensitivity
			rotation_degrees.y -= event.relative.x*sensitivity
