class_name CritRoller
extends RefCounted

var _roll: Callable # Armazena a função responsável por gerar o sorteio

func _init(roll_provider: Callable = Callable()) -> void: # Inicializa o sorteio com uma função opcional
	if roll_provider.is_valid(): # Verifica se foi fornecida uma função válida
		_roll = roll_provider # Usa a função recebida para gerar os valores
	else: # Trata a ausência de uma função válida
		_roll = func() -> float: return randf() # Define uma função que retorna um valor aleatório entre 0 e 1

# Recebe a chance em porcentagem, de 0 a 100, limitando valores fora do intervalo
func is_critical(chance_percent: float) -> bool: # Verifica se o ataque resulta em um acerto crítico
	var chance := clampf(chance_percent, 0.0, 100.0) # Limita a chance ao intervalo de 0 a 100
	var roll: float = _roll.call() * 100.0 # Executa o sorteio e converte o resultado para uma escala de 0 a 100
	return roll < chance # Retorna verdadeiro se o valor sorteado for menor que a chance
