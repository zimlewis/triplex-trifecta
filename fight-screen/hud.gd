extends CanvasLayer

@onready var enemy_leader = $enemy/enemy_banner/enemy_leader
@onready var player_leader = $player/player_banner/player_leader

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_leader.state = Card.card_state.IN_PLAY
	player_leader.state = Card.card_state.IN_PLAY



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
