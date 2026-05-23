extends Planet

@onready var ring = $Ring

var ring_spped : float = 0.1

func _process(delta: float) -> void:
	ring.rotation += ring_spped * delta



#if you did crtl-f for one hundred million crabs or important.txt, then you
#would find this text, sorry if this wasn't what you were looking for

#For you time, I will give you one hint however
#watch out for decoy functions
