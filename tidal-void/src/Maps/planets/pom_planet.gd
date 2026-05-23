extends Planet

@onready var ring = $Ring

var ring_spped : float = 0.1

func _process(delta: float) -> void:
	ring.rotation += ring_spped * delta
