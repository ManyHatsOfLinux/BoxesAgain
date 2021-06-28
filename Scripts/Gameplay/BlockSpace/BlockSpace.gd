extends Node


export (int) var BlockSize = 64
export (int) var StartingRows = 7
export (int) var BlockSpaceHeight = 12
export (int) var BlockSpaceWidth = 6
export (int) var DeathDelayMax = 4
export (int) var playernum = 0

var previous_paralized_size : int = 0
var current_paralized_size : int = 0

var fps : float = 0
var FrameCount : int = 0

#multiplies with the number of blocks destroying
export (float) var DeathDelay = .2

var BlockParent = preload("res://Scenes/Gameplay/BlockSpace/Block.tscn")

onready var FPSLabel = get_node("FPSCount")   

var ParaliyzedBlocks : Array = []

onready var cursorScene = preload("res://Scenes/Gameplay/BlockSpace/cursor.tscn")
var xcursor

#for the different Block Types
var BlockTextures = [
	preload("res://Assets/Textures/Blocks/Blue Piece.png"),
	preload("res://Assets/Textures/Blocks/Green Piece.png")
	#preload("res://Assets/Textures/Blocks/Light Green Piece.png"),
	#preload("res://Assets/Textures/Blocks/Orange Piece.png"),
	#preload("res://Assets/Textures/Blocks/Pink Piece.png"),
	#preload("res://Assets/Textures/Blocks/Yellow Piece.png"),
	#preload("res://Assets/Textures/Blocks/Black Piece.png")
]


#for sorting blocks later
class BlockSort:
	#return true if item 1 should be first in the list, otherwise return false. 
	static func sort_top_to_bottom_left_to_right(block1,block2):
		#if block is higher up
		if block1.position.y < block2.position.y :
			return true
		#if block is on same row
		elif block1.position.y == block2.position.y:
			#block is same row, but further to the left.
			if block1.position.x < block2.position.x:
				return true
			#block was further to the right
			else: 
				return false
		#block was higher.
		else: 
			return false
		
	static func sort_buttom_to_top_left_to_right(block1,block2):
		#if block is lower 
		if block1.position.y > block2.position.y :
			return true
		#if block is on same row
		elif block1.position.y == block2.position.y:
			#block is same row, but further to the left.
			if block1.position.x < block2.position.x:
				return true
			#block was further to the right
			else: 
				return false
		#block was higher.
		else: 
			return false




	static func sort_columns_then_rows(block1,block2):
		#if block is higher up
		if block1.position.x > block2.position.x :
			return true
		#if block is on same row
		elif block1.position.x == block2.position.x:
			#block is same row, but further to the left.
			if block1.position.y > block2.position.y:
				return true
			#block was further to the right
			else: 
				return false
		#block was higher.
		else: 
			return false


func _spawn_cursor():
	
	xcursor = cursorScene.instance()
	xcursor.playernum = playernum
	
	xcursor.xpos = (BlockSpaceWidth/2) -1
	xcursor.ypos = (BlockSpaceHeight/2)
	
	var xpos = (xcursor.xpos * BlockSize) + (BlockSize/2)
	var ypos = (xcursor.ypos * BlockSize) * -1
	
	xcursor.position=Vector2(xpos,ypos)
	
	add_child(xcursor)

#update cursor location
func _update_cursor_position():
	
	var xpos = (xcursor.xpos * BlockSize) + (BlockSize/2)
	var ypos = (xcursor.ypos * BlockSize) * -1
	
	xcursor.position=Vector2(xpos,ypos)

#to spawn blocks
func _spawn_block(x: int, y: int, color: int) -> void:
	
	var block = BlockParent.instance()
	block.color = color
	block.get_node("Sprite").set_texture(BlockTextures[color])
	add_child(block)
	block.add_to_group("Blocks" + str(playernum))
	
	#adjust for size of block
	x = (x*BlockSize)
	y = (y*BlockSize) * -1
	
	#set new position
	block.position = Vector2(x,y)
	block.BlockSize = BlockSize



func _spawn_starting_blocks() -> void:
	for x in BlockSpaceWidth:
		for y in StartingRows:
			var rand = floor(rand_range(0,BlockTextures.size()));
			_spawn_block(x,y,rand)


#returns 4 arrays, LEFT, DOWN, RIGHT, UP...like Vice the City weapons cheat.
func get_surrounding_blocks(Block) -> Array:
	#store all blocks in array
	var BlockList = (get_tree().get_nodes_in_group("Blocks" + str(playernum)))
	BlockList.sort_custom(BlockSort, "sort_buttom_to_top_left_to_right")

	#to store surrounding blocks
	var BlocksLEFT : Array = []
	var BlocksRIGHT : Array = []
	var BlocksDOWN : Array = []
	var BlocksUP : Array = []

	

	#Loop through all blocks getting compairing x/y values to determine 
	#relative location
	for Block2 in BlockList:
		
		#if not self
		if Block2 != self:
			
			#If on same X axis, check for up/down
			if Block.position.x == Block2.position.x :
			
				#DOWN
				#if block2 y position value is higher, its lower on screen.
				if Block.position.y < Block2.position.y:
					BlocksDOWN.append(Block2)
				
				#UP
				#and the inverse it also true. 
				elif Block2.position.y < Block.position.y: 
					BlocksUP.append(Block2)
			
			#if on same Y axis, check for left/right
			elif Block.position.y == Block2.position.y:
				
				#LEFT
				#if block2 x position is lower, its further to the left
				if Block2.position.x < Block.position.x:
					BlocksLEFT.append(Block2)
				
				#RIGHT
				if Block2.position.x > Block.position.x:
					BlocksRIGHT.append(Block2)
	
	#sort the array when we are done with them.
	for xArray in [BlocksLEFT,BlocksDOWN,BlocksRIGHT,BlocksUP]:
		xArray.sort_custom(BlockSort, "sort_buttom_to_top_left_to_right")
				
				
	return([BlocksLEFT,BlocksDOWN,BlocksRIGHT,BlocksUP])


func _update_paraliyed_list():
	#store all blocks in array
	var BlockList = (get_tree().get_nodes_in_group("Blocks" + str(playernum)))
	BlockList.sort_custom(BlockSort, "sort_top_to_bottom_left_to_right")
	
	#reset the list
	ParaliyzedBlocks = []
	
	for Block in BlockList: 
		#block is in matched state, but has not had its timers start yet.
		if int(Block.state) == 2 && Block.timers_started == false:
			ParaliyzedBlocks.append(Block)
	
	if ParaliyzedBlocks.size() > 0:
		if current_paralized_size != 0:
			previous_paralized_size = current_paralized_size
		current_paralized_size = ParaliyzedBlocks.size()


# Called when the node enters the scene tree for the first time.
func _ready():
	print("BoardReady")
	randomize()

	_spawn_cursor()
	
	if playernum == 1:
		_spawn_block(0,1,0)	
		_spawn_block(1,1,0)	
		_spawn_block(2,2,0)	
		_spawn_block(3,1,0)	
	
	if playernum == 2:
		_spawn_starting_blocks()





func _process(delta):
	
	#ensure list of paralyized blocks ais up to date
	_update_paraliyed_list()

	_update_cursor_position()

	fps = (Engine.get_frames_per_second())
	
	if FrameCount == 1000:
		FrameCount = 0
	
	FrameCount = FrameCount + 1
	#FPSLabel.set_text("FPS: " + String(fps) + " Frames Passed: " + String(FrameCount))
	FPSLabel.set_text("CurrentPlist: " + String(current_paralized_size) + " Last Paraliyed List: " + String(previous_paralized_size))

