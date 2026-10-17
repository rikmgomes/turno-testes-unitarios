class_name TurnOrder
extends RefCounted

func determine(combatants: Array) -> Array: # Determina a ordem dos combatentes com base na velocidade
	var ordered: Array = combatants.duplicate() # Cria uma cópia da lista original de combatentes
	for i in range(1, ordered.size()): # Percorre a lista a partir do segundo elemento
		var key: Combatant = ordered[i] # Armazena o combatente que será posicionado
		var j := i - 1 # Define a posição anterior ao elemento atual
		while j >= 0 and ordered[j].speed < key.speed: # Percorre os elementos anteriores com velocidade menor
			ordered[j + 1] = ordered[j] # Move o combatente mais lento uma posição à direita
			j -= 1 # Retrocede uma posição na lista
		ordered[j + 1] = key # Insere o combatente na posição correta
	return ordered # Retorna a lista ordenada da maior para a menor velocidade
