extends Area2D


var color : int 
var paralyzed : bool = false 
var DeathTimer
var RealDeathTimer 
var LabelChanged : bool = false
var lastInLine : bool = false
var ReadyToDie : bool = false
var falling : bool = false
var BlockSize : int = 0 
var fallspeed = 2

var width : int = 1
var hight : int = 1 



#To hold Block States, was not implemented when this project started
#I hope that explains the mess. Ill clean up eventually
enum {
	IDLE,
	FALLING,
	MATCHED,
	SWAPPING
}


#to hold initial state.
var state = IDLE

#stupid function becuase that I dont think I actually need.
func get_state_string() -> String:
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
		


var ShouldFall = false

#for block UI thing
var x_adj_neighbors : Array = []
var y_adj_neighbors : Array = []
var xLabelString : String = ""
var yLabelString : String = ""

onready var mySprite = get_node("Sprite")

onready var xLabelNode = get_node("xNeighbors")
onready var yLabelNode = get_node("yNeighbors")


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
		
		paralyzed = true
	
		#dim the block
		mySprite.modulate = Color(1,1,1,0.5)
		
		#send signal to BlockSpace that this block was matched
		emit_signal("Paralyze", self)





func fall():
	#print("           ",self, " Falling")
	self.falling = true
	self.position = Vector2(self.position.x,self.position.y + fallspeed)


func _get_blocks_below():
	return(get_parent().getBlocksBelow(self))



func update_labels(xlabel : String ,ylabel : String) -> void :
		
	xLabelNode.set_text( "X:" + xlabel)
	yLabelNode.set_text( "Y:" + ylabel)



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
	match state:
		
		IDLE:
			pass
		
		FALLING:
			pass
		
		MATCHED:
			pass
		
		SWAPPING:
			pass
			
	update_labels("TEST",get_state_string())
