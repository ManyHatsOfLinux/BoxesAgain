extends Node


export (int) var BlockSize = 64
export (int) var StartingRows = 7
export (int) var BlockSpaceHeight = 12
export (int) var BlockSpaceWidth = 6
export (int) var DeathDelayMax = 1

#multiplies with the number of blocks destroying
export (float) var DeathDelay = .2

var BlockParent = preload("res://Scenes/Gameplay/BlockSpace/Block.tscn")



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



#start blocks kill timer.
func MarkTheDead():
	var DeathDelayinc : float = DeathDelay 
	
	if ParalyzedBlocks.size() > 0:
		for x in range(ParalyzedBlocks.size()):
			var block = ParalyzedBlocks[x]
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
	var sizebelow : int = (BlocksBelow.size()*BlockSize)
	
	print(Block, "SizeBelow, " , sizebelow, " , y,", (Block.position.y*-1))
	
	if sizebelow != (Block.position.y*-1) :
		return true
	else:
		return false


#marks blocks that need fall this frame
func check_for_falling():
	
	#store all blocks in array
	var BlockList : Array = (get_tree().get_nodes_in_group("Blocks"))
	BlockList.sort_custom(BlockSort, "sort_buttom_to_top_left_to_right")
	
	#keep track of blocks already checked
	var BlocksAlreadyFallen : Array = []
	
	for Block in BlockList:
		var x = Block.position.x
		var y = Block.position.y
		if Block.paralyzed == false && BlocksAlreadyFallen.has([x,y]) == false: 
			#if block not already falling, And has no lower neighbors.
			if  should_fall(Block) == true :
				BlocksAlreadyFallen.append([x,y])
				Block.fall()
				

				#block is fallen mark all blocks above
				var BlocksAbove = getBlocksAbove(Block)

				for BlockX in BlocksAbove:
						BlockX.fall()
						BlocksAlreadyFallen.append([BlockX.position.x,BlockX.position.y])
						
		



# Called when the node enters the scene tree for the first time.
func _ready():
	print("BoardReady")
	randomize()


	spawn_starting_blocks()

func _process(delta):
	#print("BoardProcessStart")
	#all blocks that are matching get 
	MarkTheDead()

	#check for falling
	check_for_falling()

