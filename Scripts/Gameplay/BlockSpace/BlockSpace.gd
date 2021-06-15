extends Node


export (int) var BlockSize = 64
export (int) var StartingRows = 7
export (int) var BlockSpaceHeight = 12
export (int) var BlockSpaceWidth = 6
export (int) var DeathDelayMax = 4

var fps : float = 0
var FrameCount : int = 0

#multiplies with the number of blocks destroying
export (float) var DeathDelay = .15

var BlockParent = preload("res://Scenes/Gameplay/BlockSpace/Block.tscn")

onready var FPSLabel = get_node("FPSCount")   

#
var ParalyzedBlocks = []

#
var DyingBlocks = []



#for the different Block Types
var BlockTextures = [
	preload("res://Assets/Textures/Blocks/Blue Piece.png"),
	preload("res://Assets/Textures/Blocks/Green Piece.png")
	#preload("res://Assets/Textures/Blocks/Light Green Piece.png"),
	#preload("res://Assets/Textures/Blocks/Orange Piece.png"),
	#preload("res://Assets/Textures/Blocks/Pink Piece.png"),
	#preload("res://Assets/Textures/Blocks/Yellow Piece.png")
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



#to spawn blocks
func spawn_block(x: int, y: int, color: int) -> void:
	
	var block = BlockParent.instance()
	block.color = color
	block.get_node("Sprite").set_texture(BlockTextures[color])
	add_child(block)
	block.add_to_group("Blocks")
	
	#adjust for size of block
	x = (x*BlockSize)
	y = (y*BlockSize) * -1
	
	#set new position
	block.position = Vector2(x,y)
	block.BlockSize = BlockSize

	#connect to block signal
	block.connect("Paralyze", self, "_on_block_paralyzed")







func spawn_starting_blocks() -> void:
	for x in BlockSpaceWidth:
		for y in StartingRows:
			var rand = floor(rand_range(0,BlockTextures.size()));
			spawn_block(x,y,rand)


#to update list of blocks to keep track of match count
func _on_block_paralyzed(block):
	ParalyzedBlocks.append(block)
	ParalyzedBlocks.sort_custom(BlockSort, "sort_top_to_bottom_left_to_right")
	#print("Block Paralized")







#returns list of blocks above Block1
func getBlocksAbove(Block1) -> Array:	
	
	#store all blocks in array
	var BlockList = (get_tree().get_nodes_in_group("Blocks"))
	BlockList.sort_custom(BlockSort, "sort_buttom_to_top_left_to_right")
	
	#empty array to list all blocks above Block1
	var BlocksAbove: Array = []
	
	#loop thorugh all blocks and test if on same x axis, if so
	#check if higher on the y axis 
	for Block2 in BlockList:
		#Must be on same X axis
		if Block1.position.x == Block2.position.x :
			#if block2 y position is lower, its higher on screen.
			if Block2.position.y < Block1.position.y:
				BlocksAbove.append(Block2)
	#return list of blocks
	return BlocksAbove

#returns list of blocks above Block1
func getBlocksBelow(Block1) -> Array:	
	
	#store all blocks in array
	var BlockList = (get_tree().get_nodes_in_group("Blocks"))
	BlockList.sort_custom(BlockSort, "sort_buttom_to_top_left_to_right")
	
	#empty array to list all blocks below Block1
	var BlocksBelow: Array = []
	
	#loop thorugh all blocks and test if on same x axis, if so
	#check if higher on the y axis 
	for Block2 in BlockList:
		#Must be on same X axis
		if Block1.position.x == Block2.position.x :
			#if block2 y position is higher, its lower on screen.
			if Block2.position.y > Block1.position.y:
				BlocksBelow.append(Block2)
	#return list of blocks
	return BlocksBelow


func should_fall(Block):
	var BlocksBelow : Array = getBlocksBelow(Block) 
	var sizebelow : int = 0
	var block_y : int = Block.position.y*-1

	
	#dont fall though paralized blocks
	for Block2 in BlocksBelow:
		#reset here
		if Block2.paralyzed == true:
			
			
			sizebelow = (Block2.position.y * -1) + BlockSize
			
		#continue incrememnting
		else:
			sizebelow = sizebelow + BlockSize
	
	
	if sizebelow != block_y :
		return true
	else:
		return false


#marks blocks that need fall this frame
func check_for_falling():
	
	#store all blocks in array
	var BlockList : Array = (get_tree().get_nodes_in_group("Blocks"))
	BlockList.sort_custom(BlockSort, "sort_buttom_to_top_left_to_right")
	
	
	
	for Block in BlockList:
		Block.falling = false
		
		if Block.paralyzed == false : 
			#if block not already falling, And has no lower neighbors.
			if  should_fall(Block) == true :
				Block.falling = true
				



func ParalizeMatchingBlocks():
	
	#store all blocks in array listen Horizontally
	var HBlockList : Array = (get_tree().get_nodes_in_group("Blocks"))
	HBlockList.sort_custom(BlockSort, "sort_buttom_to_top_left_to_right")
	
	var VBlockList : Array = (get_tree().get_nodes_in_group("Blocks"))
	VBlockList.sort_custom(BlockSort, "sort_columns_then_rows")


	
	var currentRow : int = 0
	var currentColumn : int = 0
	var lastHColorSeen : int = -1
	var lastVColorSeen : int = -1
	var lastX : int = 10000
	var lastY : int = 10000
	
	
	#list of blocks sharing same color on this row
	var Hmatchlist : Array = []
	var Vmatchlist : Array = []
	
	for z in range(HBlockList.size()):
		var Hblock = HBlockList[z]
		var Vblock = VBlockList[z]
		
		var h_x = Hblock.position.x
		var h_y = Hblock.position.y
		
		var v_x = Vblock.position.x
		var v_y = Vblock.position.y
		
		
		
		
		#reset row if color changed or on new row
		if h_y != currentRow or lastHColorSeen != Hblock.color or (h_x - lastX) != 64 or Hblock.paralyzed == true or Hblock.falling == true:
			Hmatchlist = []
		currentRow = h_y
		lastHColorSeen = Hblock.color
		lastX = h_x
		
		#reset colum matches if on new column
		if v_x != currentColumn or lastVColorSeen != Vblock.color or (v_y - lastY) != -64 or Vblock.paralyzed == true or Vblock.falling == true:
			Vmatchlist = []
		currentColumn = v_x 
		lastVColorSeen = Vblock.color
		lastY = v_y
		
		#add current block

		Hmatchlist.append(Hblock)

		Vmatchlist.append(Vblock)
			
			
		#if matchcount 3 or mroe
		if Hmatchlist.size() == 3:
			for HBlock2 in Hmatchlist:
				if ParalyzedBlocks.has(HBlock2) == false:
					ParalyzedBlocks.append(HBlock2)

		elif Hmatchlist.size() > 3:
			if ParalyzedBlocks.has(Hblock) == false:
				ParalyzedBlocks.append(Hblock)

				
		#if matchcount 3
		if Vmatchlist.size() == 3:
			for VBlock2 in Vmatchlist:
				if ParalyzedBlocks.has(VBlock2) == false:
					ParalyzedBlocks.append(VBlock2)
				
		elif Vmatchlist.size() > 3:
			if ParalyzedBlocks.has(Vblock) == false:
				ParalyzedBlocks.append(Vblock)


	StartBlockKillTimers()
	



#start blocks kill timer.
func StartBlockKillTimers():
	var DeathDelayinc : float = DeathDelay 
	
	ParalyzedBlocks.sort_custom(BlockSort, "sort_top_to_buttom_left_to_right")
	print(ParalyzedBlocks)
	
	if ParalyzedBlocks.size() > 0:
		for x in range(ParalyzedBlocks.size()):
			
			if ParalyzedBlocks[x].paralyzed == false:
				var block = ParalyzedBlocks[x]
				block._paralyze()
			
				var RealDeathDelay = (DeathDelay*2) + (DeathDelay*ParalyzedBlocks.size())
			
			
				#incremebent delay incremembet if not past the max
				if DeathDelayinc < DeathDelayMax:
					DeathDelayinc = DeathDelay + DeathDelayinc

			#
				if RealDeathDelay > DeathDelayMax:
					RealDeathDelay = (DeathDelayMax)

				block.killTimer(DeathDelayinc, RealDeathDelay)
	
		print("Marked ", ParalyzedBlocks.size(), " Blocks.")
		ParalyzedBlocks = []




# Called when the node enters the scene tree for the first time.
func _ready():
	print("BoardReady")
	randomize()



	#spawn_block(0,0,1)	
	#spawn_block(0,1,1)
	#spawn_block(0,2,1)
	#spawn_block(0,3,0)
	spawn_starting_blocks()





func _process(delta):
	print("Frame Passed")
	

	#find matching blocks
	ParalizeMatchingBlocks()	
	
	#check for falling
	check_for_falling()

	
	fps = (Engine.get_frames_per_second())
	
	if FrameCount == 1000:
		FrameCount = 0
	
	FrameCount = FrameCount + 1
	FPSLabel.set_text("FPS: " + String(fps) + " Frames Passed: " + String(FrameCount))




	
