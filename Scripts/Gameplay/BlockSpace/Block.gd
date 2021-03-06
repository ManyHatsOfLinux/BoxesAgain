extends Area2D


onready var playernum = get_parent().playernum

#used in matching
var color : int 

#pixels to fall per call to _fall()
var fallspeed : int = 4

var swapspeed : int = 8

#pixels the block is off its y axis by (for correcting fall...
#calculations when blocks are being pushed)
var yoffset : int = 0

#used to store block size (default 1x1)
var width: int = 1
var hight: int = 1

var BlockSpaceHeight : int = 0

#to store surrounding blocks
var BlocksLEFT : Array = []
var BlocksRIGHT : Array = []
var BlocksDOWN : Array = []
var BlocksUP : Array = []

#for fall detection to know if swapping is applicable
var ULBlock 
var URBlock

#size of block in pixels (per previous unit eg ...
# 1x1 block would be 64x64 in size by default)
var BlockSize : int = 0


#To hold Block States, was not implemented when this project started
#I am hopefully cleaning the mess now. 
enum {
	#has not been fully spawned yet.
	UNBORN,
	
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
var state = UNBORN


#is gravity getting you down?
var is_falling : bool = false

#set to true as a block returns to idle
var just_finished_swapping = false

#one way ticket
var timers_started : bool = false


#left is 0, right is 1
var SwapDirection : bool = 0


#to store itself
onready var mySprite = get_node("Sprite")


#kinda backwards but okay.
func _get_state_string() -> String:
	match int(state):
		
		0:
			return("UNBORN")
		1:
			return("IDLE")
		2: 
			return ("FALLING")
		3: 
			return ("MATCHED")
		4: 
			return ("SWAPPING")
		_:
			return("ERROR")



#get offset from boardspace
func _update_offset():
	yoffset = get_parent().yoffset 

#update labels with new strings
func _update_labels(xlabel : String ,ylabel : String) -> void :
		
	get_node("xLabel").set_text(xlabel)
	get_node("yLabel").set_text(ylabel)


#ahhhhhhh...
func _start_falling():
	self.add_to_group("FALLING" + str(playernum))
	state = FALLING


#hhhh!....splat
func _stop_falling():
	self.remove_from_group("FALLING" + str(playernum))
	self.add_to_group("DoneFalling" + str(playernum))


#weeeee
func _fall():
	self.position = Vector2(self.position.x,self.position.y + fallspeed)
	is_falling = true

#lazy blocks
func _start_idleing():
	state = IDLE


#no going back from here
func _start_matching():
	self.add_to_group("MATCHED" + str(playernum))
	state = MATCHED


func _dim():
	#dim the block
	mySprite.modulate = Color(1,1,1,0.5)



#returns true if blocks below dont add up to itself.
func _should_fall() -> bool :
	
	#only bother checking for fall conditions
	#if not matched, not swapping, or above ground.
	if not timers_started or state != SWAPPING or position.y < 0:
	
		var sizebelow : int = 0
		var block_y : int = self.position.y*-1
		
		_update_offset()

		#loop through blocks below and increment sizebelow see if there is space
		#between this blocks and 0 thats not blocks.
		for Block in range(BlocksDOWN.size()):
			var Block2 = BlocksDOWN[Block]

			#Blocks Above Ground on at ground level
			if Block2.position.y <= 0:

				#dont fall though paralized blocks	sizebelow reset here
				if [MATCHED,SWAPPING].has(Block2.state) :

					#if (Block2.position.y * -1) + BlockSize > sizebelow:
						sizebelow = (Block2.position.y * -1) + BlockSize - yoffset

				#continue incrememnting normal block
				else:
					sizebelow = sizebelow + BlockSize

			
			
		if sizebelow != block_y - yoffset :
			#print("True: ","SizeBelow:", sizebelow , " Block-Offset:", block_y - yoffset)
			#print("Yoffset:",yoffset, "  Ypos:",block_y, " ")
			#print("Size:",BlocksDOWN.size())
			for x in BlocksDOWN:
				#print( BlocksDOWN.find(x), " at Ypos: ",x.position.y)
				pass
			return true


	return false


#returns true if blocks below dont add up to itself.
func _should_fallBackup() -> bool :
	
	#if matched or swapping
	if not timers_started or state != SWAPPING or position.y < 0:
	
		var sizebelow : int = 0
		var block_y : int = self.position.y*-1
		
		_update_offset()

		if BlocksDOWN.size() * BlockSize != block_y - yoffset:
			#print(BlocksDOWN.size())
			#should fall
			return true
	#should not fall
	return false


#returns true if not falling or matchign, or swapping
func _can_match() -> bool:
	if [SWAPPING,FALLING,UNBORN].has(state) or timers_started or is_falling :
		#cannot match
		return false
	#can match
	return true


#returns true or false depending on if in a match
func _should_match() -> bool:


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


#use raycasts to get neighboring blocks
func _get_neighbors()->void:
	
	#reset arrays
	BlocksLEFT  = []
	BlocksRIGHT = []
	BlocksDOWN  = []
	BlocksUP    = []


	#LEFT/RIGHT
	var vBlocks = get_parent().verticalYBlocks
	
	for x in range(vBlocks.size()):
		
		#block was found on list
		var searchResult = vBlocks[x].find(self)
		#if block is contained in array
		if searchResult != -1:
			
			#print(vBlocks[x])
			#add left blocks to BlocksLEFT
			for z in vBlocks[x]:
				#if block xpos in list is less that self, 
				#the block is left of this one. 
				if z.position.x < self.position.x:
					BlocksLEFT.append(z)
				elif z.position.x > self.position.x:
					BlocksRIGHT.append(z)


	#UP/DOWN
	var hBlocks = get_parent().horizontalXBlocks
	
	for x in range(hBlocks.size()):
		
		#block was found on list
		var searchResult = hBlocks[x].find(self)
		#if block is contained in array
		if searchResult != -1:
			
			#print(vBlocks[x])
			#add left blocks to BlocksLEFT
			for z in hBlocks[x]:
				#if block ypos in list is less than self, 
				#the block is higher than this one. 
				if z.position.y < self.position.y:
					BlocksUP.append(z)
				elif z.position.y > self.position.y:
					if BlocksDOWN.has(z):
						print("ERROROROROR")
					BlocksDOWN.append(z)
	




	#UP-LEFT	
	var ULRay  = get_node("ULRay")
	ULBlock = ULRay.get_collider()
	
	
	#UP-RIGHT
	var URRay  = get_node("URRay")
	URBlock = URRay.get_collider()



#turn the block invisible
func _on_DeathTimer_Timeout_():
	#turn invisible
	mySprite.modulate = Color(1,1,1,0)


#destroy the block
func _on_RealDeathTimer_Timeout_():
	self.remove_from_group("MATCHED" + str(playernum))
	self.add_to_group("DED" + str(playernum))


#blocks turns invisible after time, dies after RealTime
func _start_death_timers():

	
	#so this doesn't run on top of itself
	timers_started = true
	
	
	#get number of blocks paralized.
	var total = get_parent().ParaliyzedBlocks.size()
	var localpos = get_parent().ParaliyzedBlocks.find(self)
	
	var DeathDelay = get_parent().DeathDelay
	var DeathDelayMax = get_parent().DeathDelayMax
	var time = (localpos + 1) * DeathDelay
	var RealTime = (total + 1) * DeathDelay
	
	#set a cap on deathdelay
	if RealTime > DeathDelayMax:
		RealTime = DeathDelayMax
	
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


func can_swap(Direction : bool) -> bool:
	if state == IDLE && just_finished_swapping == false:
		#going left
		if Direction == false:
			#if block exists
			if ULBlock:
				if ULBlock.state != FALLING:
					return true
			else: 
				return true
		

		#going right
		if Direction == true:
			if URBlock:
				if URBlock.state != FALLING:
					return true
			else:
				return true
	
	
	return false


func start_swapping(NewSwapDirection : bool) -> void:
		state = SWAPPING
		SwapDirection = NewSwapDirection

func _is_done_swapping() -> bool:
	if int(self.mySprite.position.x) % BlockSize == 0:
		return true
	return false

func _exit_swapping():
	#hold position of sprite
	var newpos = Vector2(self.mySprite.global_position)
	#set sprite back to parent
	self.mySprite.position = Vector2(0,0)
	#set postion to postion sprite used to be.
	self.global_position = newpos

func _keep_swapping():
	#going left
	if SwapDirection == bool(0):
		self.mySprite.position = Vector2(self.mySprite.position.x - swapspeed ,self.mySprite.position.y)
	#going right
	else: 
		self.mySprite.position = Vector2(self.mySprite.position.x + swapspeed ,self.mySprite.position.y)


func _process(delta):
	
	#AUTO_KILL
	if (self.position.y * -1) > BlockSize * (BlockSpaceHeight-1) \
	or (self.position.y * -1) < (BlockSize * -1):
		queue_free()
	

	_get_neighbors()
	
	#update state label for easier debug
	_update_labels("Y:" + str(self.position.y),_get_state_string())



	match state:
		
		UNBORN: 
			#block is below ground
			if self.position.y > 0:
				mySprite.modulate = Color(.41,.41,.41,0.5)
			#block is level with ground
			elif self.position.y <= 0:
				state = IDLE
				mySprite.modulate = Color(1,1,1,1)
		
		
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

			#falling to matchign
			#falling wont go atraight into matching because blocsk have processed
			#already before the block will change its state
			
			#falling to idleing
			else: 
				_stop_falling()
				_start_idleing()
				
		#block is matched, this is the last stop.
		MATCHED:
			#matched and has not set its death timers yet...
			if timers_started == false:
				_dim()
				_start_death_timers()
			
			
		#block is swapping, could be matched, start falling, or become idle.
		SWAPPING:
			#pushes block over to left/right
			_keep_swapping()
			
			#swapping is done, time to change state
			if _is_done_swapping():
				
				#reset postion to match sprite movement
				_exit_swapping()
				
				#swapping to falling
				if _should_fall():
					_start_falling()
					
				else:
					_start_idleing()
					just_finished_swapping = true
					self.add_to_group("SwappingDone" + str(playernum))
				
