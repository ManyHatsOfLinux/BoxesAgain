extends Area2D


var color : int 
var paralyzed : bool = false 
var DeathTimer
var RealDeathTimer 
var lastInLine : bool = false
var ReadyToDie : bool = false
var falling : bool = false
var BlockSize : int = 0 
var fallspeed = 2

var ShouldFall = false

var x_adj_neighbors : Array = []
var y_adj_neighbors : Array = []

onready var mySprite = get_node("Sprite")

signal Paralyze(block)



func _ready():
	#print("BlockReady")
	pass



func _on_Block_area_entered(area):
	#print(self, " has been Area_Enterd")
	#update_adj_neighbors()
	#match_self()
	pass


func _paralyze():
	if paralyzed == false:
		
		paralyzed = true
	
		#dim the block
		mySprite.modulate = Color(1,1,1,0.5)
		
		#send signal to BlockSpace that this block was matched
		emit_signal("Paralyze", self)



func fall():
	print("           ",self, " Falling")
	self.falling = true
	self.position = Vector2(self.position.x,self.position.y + fallspeed)
	pass


func update_adj_neighbors():
	#reset neighbor variables
	x_adj_neighbors = []
	y_adj_neighbors = []
	
	#loop though all blocks touching this block.
	for neighbor in get_overlapping_areas():
		
		#if neighbor is on the same X axis and share the same color
		if (neighbor.position.x == self.position.x) && (neighbor.color == self.color):
			if neighbor.falling == false:
				y_adj_neighbors.append(neighbor)
		
		#if neighbor is on the same Y axis and share the same color
		elif (neighbor.position.y == self.position.y) && (neighbor.color == self.color):
			if neighbor.falling == false:
				x_adj_neighbors.append(neighbor)
		
	get_node("xNeighbors").set_text( "X:" + str(x_adj_neighbors.size()))
	get_node("yNeighbors").set_text( "Y:" + str(y_adj_neighbors.size()))




func match_self():
	if self.falling == false:
		if x_adj_neighbors.size() == 2:
			self._paralyze()
			for x in x_adj_neighbors:
				x._paralyze()
	
		if y_adj_neighbors.size() == 2:
			self._paralyze()
			for y in y_adj_neighbors:
				y._paralyze()




func killTimer(time: float, RealTime: float):
	DeathTimer = Timer.new()
	DeathTimer.connect("timeout", self, "_on_DeathTimer_Timeout_")
	DeathTimer.set_wait_time(time)
	add_child(DeathTimer)
	
	
	RealDeathTimer = Timer.new()
	RealDeathTimer.connect("timeout", self, "_on_RealDeathTimer_Timeout_")
	RealDeathTimer.set_wait_time(RealTime)
	add_child(RealDeathTimer)
	
	DeathTimer.start()
	RealDeathTimer.start()

func _on_DeathTimer_Timeout_():
	mySprite.modulate = Color(1,1,1,0)
	DeathTimer.stop()
	ReadyToDie = true



func _on_RealDeathTimer_Timeout_():
	queue_free()

func _process(delta):
	if falling == false:
		update_adj_neighbors()
		match_self()
	self.falling = false
	pass
