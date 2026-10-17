class_name Combatant
extends RefCounted

var display_name: String # Armazena o nome do combatente
var attack: int # Armazena o valor de ataque
var defense: int # Armazena o valor de defesa
var speed: int # Armazena a velocidade usada na ordem dos turnos
var crit_chance: float  # Armazena a chance de acerto crítico em porcentagem, de 0 a 100
var health: Health # Armazena o estado de vida do combatente

func _init(p_name: String, max_hp: int, p_attack: int, p_defense: int, p_speed: int, p_crit_chance: float = 0.0) -> void: # Inicializa o combatente com seus atributos
	display_name = p_name # Define o nome do combatente
	attack = p_attack # Define o valor de ataque
	defense = p_defense # Define o valor de defesa
	speed = p_speed # Define a velocidade
	crit_chance = p_crit_chance # Define a chance de acerto crítico
	health = Health.new(max_hp) # Cria o controle de vida com os pontos de vida máximos

func is_alive() -> bool: # Verifica se o combatente está vivo
	return not health.is_dead() # Retorna verdadeiro se o combatente não estiver morto
