class_name DamageCalculator
extends RefCounted

const CRIT_MULTIPLIER := 2.0 # Define o multiplicador de dano para acertos críticos

func calculate(attack: int, defense: int, bonus: int = 0, is_critical: bool = false) -> int:
	var raw := attack + bonus # Soma o ataque ao bônus para obter o dano bruto
	if is_critical: # Verifica se o ataque é crítico
		raw = int(raw * CRIT_MULTIPLIER) # Multiplica o dano bruto e converte o resultado para inteiro
	return maxi(0, raw - defense) # Subtrai a defesa e garante que o dano não seja negativo
	#return raw - defense # Alternativa que não limita o dano mínimo a zero (exemplo de erro no teste)
