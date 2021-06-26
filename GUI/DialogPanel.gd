extends PanelContainer

onready var min_size = rect_size

func resize():
	self.rect_size = min_size
