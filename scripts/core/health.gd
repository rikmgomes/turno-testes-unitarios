class_name Health
extends RefCounted

signal died # Emite um sinal quando a vida chega a zero
signal changed(current: int, maximum: int) # Emite um sinal quando a vida muda, informando os valores atual e máximo

var max_hp: int # Armazena a quantidade máxima de vida
var current: int # Armazena a quantidade atual de vida

func _init(p_max_hp: int) -> void: # Inicializa a vida com o valor máximo informado
	max_hp = maxi(1, p_max_hp) # Garante que a vida máxima seja pelo menos 1
	current = max_hp # Define a vida atual como máxima

func is_dead() -> bool: # Verifica se o personagem está morto
	return current <= 0 # Retorna verdadeiro se a vida for zero ou inferior

func take_damage(amount: int) -> void: # Aplica dano à vida atual
	if amount <= 0 or is_dead(): # Verifica se o dano é inválido ou se o personagem já morreu
		return # Ignora danos nulos, negativos ou recebidos após a morte
	current = maxi(0, current - amount) # Subtrai o dano sem permitir vida abaixo de zero
	changed.emit(current, max_hp) # Emite o sinal com os valores atualizados de vida
	if current == 0: # Verifica se a vida chegou a zero
		died.emit() # Emite o sinal de morte

func heal(amount: int) -> int: # Recupera vida e retorna a quantidade efetivamente restaurada
	if amount <= 0 or is_dead(): # Impede cura com valores inválidos ou após a morte
		return 0 # Retorna zero quando a cura não pode acontecer
	var before := current # Armazena a vida antes da cura
	current = mini(max_hp, current + amount) # Soma a cura sem ultrapassar a vida máxima
	var healed := current - before # Calcula a quantidade de vida efetivamente recuperada
	if healed > 0: # Verifica se houve recuperação de vida
		changed.emit(current, max_hp) # Emite o sinal com os valores atualizados de vida
	return healed # Retorna a quantidade de vida recuperada
