extends Node

var xpos : int = 0
var ypos : int = 0

var height : int = 0
var width : int = 0

var playernum : int = 0 

var BlockSize : int = 0

onready var SnapNode = get_node("Snap")

# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.



#update labels with new strings
func _update_labels(xlabel : String ,ylabel : String) -> void :
		
	get_node("xLabel").set_text(xlabel)
	get_node("yLabel").set_text(ylabel)



func _input(ev):

	if playernum == 1 or playernum == 10:

		#UP
			if Input.is_action_just_pressed("ui_up"):
				if ypos < (height-1):
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
				if xpos < (width-2):
					xpos = xpos + 1
					
		
		#Space/Swap
			if Input.is_action_just_pressed("ui_select"):
				
				
				#get left block
				var LeftRay = get_node("LeftRay")
				var LBlock = LeftRay.get_collider()
				
				#get right block
				var RightRay = get_node("RightRay")
				var RBlock = RightRay.get_collider()
	
				#if both blocks exist
				if LBlock && LBlock.can_swap(bool(1)) && RBlock && RBlock.can_swap(bool(0)): 
					LBlock.start_swapping(bool(1))
					RBlock.start_swapping(bool(0))
					SnapNode.play()
				
				#only left block exists.
				elif RBlock == null && LBlock && LBlock.can_swap(bool(1)):
					LBlock.start_swapping(bool(1))
					SnapNode.play()
				#only right block eixists
				elif LBlock == null && RBlock && RBlock.can_swap(bool(0)):
					RBlock.start_swapping(bool(0))
					SnapNode.play()
					
					
	if playernum == 2 :
		#UP
			if Input.is_action_just_pressed("ui_up2"):
				if ypos < (height-1):
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
				if xpos < (width-2):
					xpos = xpos + 1

func _process(delta):
	_update_labels(("X:" + str(xpos)),"Y:" + str(ypos) )

	#drop cursor down 1 level if above boarder
	if self.position.y < (BlockSize * -1) * (height-1):
		print("Cursor At:",self.position.y)
		ypos = ypos-1
		
