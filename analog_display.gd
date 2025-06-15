extends Node2D

@export var clock_container: CenterContainer

func _on_clock_container_resized() -> void:
	self.global_position = clock_container.get_rect().get_center()
