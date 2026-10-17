class_name PotionBag
extends RefCounted

var count: int # Armazena a quantidade de poções disponíveis
var heal_amount: int # Armazena a quantidade de vida recuperada por poção

func _init(initial_count: int, p_heal_amount: int = 30) -> void: # Inicializa a bolsa com uma quantidade de poções e um valor de cura
	count = maxi(0, initial_count) # Garante que a quantidade inicial de poções seja pelo menos zero
	heal_amount = p_heal_amount # Define a quantidade de vida recuperada por poção

func can_use(target: Combatant) -> bool: # Verifica se o alvo pode usar uma poção
	return count > 0 and target.is_alive() and target.health.current < target.health.max_hp # Exige poções disponíveis, alvo vivo e vida abaixo do máximo

func use(target: Combatant) -> bool: # Tenta usar uma poção no combatente informado
	if not can_use(target): # Verifica se o uso da poção é permitido
		return false # Retorna falso se a poção não puder ser usada
	count -= 1 # Consome uma poção da bolsa
	target.health.heal(heal_amount) # Recupera a vida do alvo conforme o valor de cura definido
	return true # Retorna verdadeiro para indicar que a poção foi usada
