extends Node

var xpos : int = 0
var ypos : int = 0

var playernum : int = 0 


# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.



#update labels with new strings
func _update_labels(xlabel : String ,ylabel : String) -> void :
		
	get_node("xLabel").set_text(xlabel)
	get_node("yLabel").set_text(ylabel)




func _input(ev):

	if playernum == 1 :

		#UP
			if Input.is_action_just_pressed("ui_up"):
				if ypos < 11:
					ypos = ypos + 1


		#DOWN
			if Input.is_action_just_pressed("ui_down"):
				if ypos > 0:
					ypos = ypos - 1

		#LEFT
			if Input.is_action_just_pressed("ui_left"):
				if xpos > 0 :
					xpos = xpos - 1

		#RIGHT
			if Input.is_action_just_pressed("ui_right"):
				if xpos <= 3:
					xpos = xpos + 1

	if playernum == 2 :

		#UP
			if Input.is_action_just_pressed("ui_up2"):
				if ypos < 11:
					ypos = ypos + 1

				
		#DOWN
			if Input.is_action_just_pressed("ui_down2"):
				if ypos > 0:
					ypos = ypos - 1

		#LEFT
			if Input.is_action_just_pressed("ui_left2"):
				if xpos > 0 :
					xpos = xpos - 1

		#RIGHT
			if Input.is_action_just_pressed("ui_right2"):
				if xpos <= 3:
					xpos = xpos + 1

func _process(delta):
	_update_labels(("X:" + str(xpos)),"Y:" + str(ypos) )
