extends Area2D


#used in matching
var color : int 


#pixels to fall per call to _fall()
var fallspeed : int = 2


#used to store block size (default 1x1)
var width: int = 1
var hight: int = 1


#to store surrounding blocks
var BlocksLEFT : Array = []
var BlocksRIGHT : Array = []
var BlocksDOWN : Array = []
var BlocksUP : Array = []


#size of block in pixels (per previous unit eg ...
# 1x1 block would be 64x64 in size by default)
var BlockSize : int = 0


#To hold Block States, was not implemented when this project started
#I am hopefully cleaning the mess now. 
enum {
	#not moving or anything
	IDLE,
	#doing the gravity thing
	FALLING,
	#block was matched up with similar blocks, good job!
	MATCHED,
	#block is moving around like crazy. who knows whats going on.
	SWAPPING
}


#to hold initial state.
var state = IDLE


#is gravity getting you down?
var is_falling : bool = false


#one way ticket
var timers_started : bool = false


#to store itself
onready var mySprite = get_node("Sprite")
 

#kinda backwards but okay.
func _get_state_string() -> String:
	match int(state):
		
		0:
			return("IDLE")
		1: 
			return ("FALLING")
		2: 
			return ("MATCHED")
		3: 
			return ("SWAPPING")
		_:
			return("ERROR")


#update labels with new strings
func _update_labels(xlabel : String ,ylabel : String) -> void :
		
	get_node("xLabel").set_text(xlabel)
	get_node("yLabel").set_text(ylabel)


#get blocks around
func _update_neighbors():
	var BlockArray = (get_parent().get_surrounding_blocks(self))
	
	BlocksLEFT  = BlockArray[0]
	BlocksDOWN  = BlockArray[1]
	BlocksRIGHT = BlockArray[2]
	BlocksUP    = BlockArray[3]


#ahhhhhhh...
func _start_falling():
	state = FALLING
	is_falling = true
	_fall()


#hhhh!....splat
func _stop_falling():
	is_falling = false


#set the new state
func _start_idleing():
	state = IDLE


#no going back from here
func _start_matching():
	
	#dim the block
	mySprite.modulate = Color(1,1,1,0.5)

	state = MATCHED

#weeeee
func _fall():
	#push block down by int(fallspeed) pixels
	self.position = Vector2(self.position.x,self.position.y + fallspeed)


#returns true if blocks below dont add up to itself.
func _should_fall() -> bool :
	
	var sizebelow : int = 0
	var block_y : int = self.position.y*-1

	
	#loop through blocks below and increment sizebelow see if there is space
	#between this blocks and 0 thats not blocks.
	for Block2 in BlocksDOWN:
	
		#dont fall though paralized blocks	sizebelow reset here
		if Block2.state == MATCHED:
			
			sizebelow = (Block2.position.y * -1) + BlockSize
			
		#continue incrememnting
		else:
			sizebelow = sizebelow + BlockSize
	
	
	if sizebelow != block_y :
		return true
	else:
		return false

#returns true if not falling or matchign, or swapping
func _can_match() -> bool:
	if [SWAPPING].has(state) or timers_started or is_falling :
		return false
	return true


#returns true or false depending on if in a match
func _should_match() -> bool:
	
	#keep count of matching surroudning blocks
	var matchedBlocks : int = 0
	
	#if this block is not falling swapping or already matching
	if _can_match():
	
	
		#two2left
		#so long as at least two blocks are to the left.
		if BlocksLEFT.size() > 1:
			var LBlock1 = BlocksLEFT[BlocksLEFT.size() - 1]
			var LBlock2 = BlocksLEFT[BlocksLEFT.size() - 2]
			var Lpos1 = LBlock1.position.x
			var Lpos2 = LBlock2.position.x
			var selfpos = self.position.x
			
			if LBlock1.color == self.color && self.color == LBlock2.color \
			&& Lpos1 == (selfpos - BlockSize) && Lpos2 == (selfpos - (BlockSize*2))\
			&& LBlock1._can_match() && LBlock2._can_match() :
				return true


		#hmiddle
		#both array's must have at least 1 block to check for this
		if BlocksLEFT.size() >= 1 && BlocksRIGHT.size() >= 1 : 
			
			var LBlock = BlocksLEFT[BlocksLEFT.size() - 1]
			var RBlock = BlocksRIGHT[0]
			var Lpos = LBlock.position.x
			var Rpos = RBlock.position.x
			var selfpos = self.position.x 
			
			#if colors are the same and X values lign up
			if LBlock.color == self.color && RBlock.color == self.color \
			&& Lpos == (selfpos - BlockSize) && Rpos == (selfpos + BlockSize)\
			&& LBlock._can_match() && RBlock._can_match() :
				return true


		#two2right
		#if more than one block to the right
		if BlocksRIGHT.size() > 1:
			
			var RBlock1 = BlocksRIGHT[0]
			var RBlock2 = BlocksRIGHT[1]
			var Rpos1 = RBlock1.position.x
			var Rpos2 = RBlock2.position.x
			var selfpos = self.position.x
			
			if RBlock1.color == self.color && self.color == RBlock2.color \
			&& Rpos1 == (selfpos + BlockSize) && Rpos2 == (selfpos + (BlockSize*2))\
			&& RBlock1._can_match() && RBlock2._can_match():
				return true


		#twoabove
		if BlocksUP.size() > 1: 
			
			#pull from the back of the list to get the closest blocks.
			var UBlock1 = BlocksUP[0]
			var UBlock2 = BlocksUP[1]
			var Upos1 = UBlock1.position.y * -1
			var Upos2 = UBlock2.position.y * -1 
			var selfpos = self.position.y * -1
			
			if UBlock1.color == self.color && UBlock2.color == self.color \
			&& Upos1 == (selfpos + BlockSize ) && Upos2 == (selfpos + (BlockSize *2))\
			&& UBlock1._can_match() && UBlock2._can_match():
				return true


		#vmiddle
		if BlocksUP.size() >= 1 && BlocksDOWN.size() >= 1 : 
			
			var UBlock = BlocksUP[0]
			var DBlock = BlocksDOWN[BlocksDOWN.size() - 1]
			var Upos = UBlock.position.y  * -1
			var Dpos = DBlock.position.y  * -1
			var selfpos = self.position.y * -1
	
			if UBlock.color == self.color && DBlock.color == self.color\
			&& Upos == (selfpos + BlockSize) && Dpos == (selfpos - BlockSize)\
			&& UBlock._can_match() && DBlock._can_match():
				return true


		#twobelow 
		if BlocksDOWN.size() > 1 : 
			
			var DBlock1 = BlocksDOWN[BlocksDOWN.size() - 1]
			var DBlock2 = BlocksDOWN[BlocksDOWN.size() - 2]
			var Dpos1 = DBlock1.position.y  * -1
			var Dpos2 = DBlock2.position.y  * -1
			var selfpos = self.position.y   * -1
	
			if DBlock1.color == self.color && DBlock2.color == self.color\
			&& Dpos1 == (selfpos - BlockSize) && Dpos2 == (selfpos - (BlockSize * 2))\
			&& DBlock1._can_match() && DBlock2._can_match():
				return true


	return false


#turn the block invisible
func _on_DeathTimer_Timeout_():
	#turn invisible
	mySprite.modulate = Color(1,1,1,0)


#destroy the block
func _on_RealDeathTimer_Timeout_():
	queue_free()

#blocks turns invisible after time, dies after RealTime
func _start_death_timers():

	
	#so this doesn't run on top of itself
	timers_started = true
	
	
	#get number of blocks paralized.
	var total = get_parent().ParaliyzedBlocks.size()
	var localpos = get_parent().ParaliyzedBlocks.find(self)
	
	var DeathDelay = get_parent().DeathDelay
	var time = (localpos + 1) * DeathDelay
	var RealTime = (total + 1) * DeathDelay
	
	#set a cap on deathdelay
	if RealTime > 2:
		RealTime = 2
	
	var DeathTimer = Timer.new()
	DeathTimer.connect("timeout", self, "_on_DeathTimer_Timeout_")
	DeathTimer.set_wait_time(time)
	add_child(DeathTimer)
	
	
	var RealDeathTimer = Timer.new()
	RealDeathTimer.connect("timeout", self, "_on_RealDeathTimer_Timeout_")
	RealDeathTimer.set_wait_time(RealTime)
	add_child(RealDeathTimer)
	
	DeathTimer.start()
	RealDeathTimer.start()


func _process(delta):
	
	#update lists of neighbors
	_update_neighbors()
	
	#update state label for easier debug
	_update_labels("0",_get_state_string())


	match state:
		
		#this game should be called lazy blocks
		#block could fall, swapped, or matched
		IDLE:
			#idle to falling
			if _should_fall():
				_start_falling()
			
			
			#idle to matching
			elif _should_match():
				_start_matching()
			
		
		#ive been falling already, could stop falling, match, or return to idle.
		FALLING:
			#still falling
			if _should_fall():
				_fall()
			
			elif _should_match() :
				_stop_falling()
				_start_matching()
			
			#falling to idleing
			else: 
				_stop_falling()
				_start_idleing()
				
		#block is matched, this is the last stop.
		MATCHED:
			#matched and has not set its death timers yet...
			if timers_started == false:
				 _start_death_timers()
			
			
		#block is swapping, could be matched, start falling, or become idle.
		SWAPPING:
			pass
	



