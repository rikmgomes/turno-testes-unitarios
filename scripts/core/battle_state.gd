class_name BattleState
extends RefCounted # Permite criar objetos sem serem nós da árvore de cena

enum Result { ONGOING, HERO_WON, HERO_LOST, DRAW } # Define os possíveis resultados da batalha

signal battle_ended(result: Result) # Emite o resultado quando a batalha termina

var hero: Combatant # Armazena o combatente do herói
var monster: Combatant # Armazena o combatente do monstro

var _calculator := DamageCalculator.new() # Cria o calculador de dano
var _order := TurnOrder.new() # Cria o controlador da ordem dos turnos
var _crit: CritRoller # Armazena o responsável por verificar acertos críticos
var _finished := false # Indica se o encerramento da batalha já foi registrado

func _init(p_hero: Combatant, p_monster: Combatant, crit_roller: CritRoller = null) -> void: # Inicializa a batalha
	hero = p_hero # Define o herói da batalha
	monster = p_monster # Define o monstro da batalha
	_crit = crit_roller if crit_roller != null else CritRoller.new() # Usa o calculador recebido ou cria um novo

func get_result() -> Result: # Retorna o resultado atual da batalha
	var hero_dead := hero.health.is_dead() # Verifica se o herói está morto
	var monster_dead := monster.health.is_dead() # Verifica se o monstro está morto
	if hero_dead and monster_dead: # Verifica se ambos morreram
		return Result.DRAW # Retorna empate
	if monster_dead: # Verifica se apenas o monstro morreu
		return Result.HERO_WON # Retorna vitória do herói
	if hero_dead: # Verifica se apenas o herói morreu
		return Result.HERO_LOST # Retorna derrota do herói
	return Result.ONGOING # Retorna que a batalha continua

func is_finished() -> bool: # Verifica se a batalha terminou
	return get_result() != Result.ONGOING # Retorna verdadeiro se o resultado não for de batalha em andamento

func turn_sequence() -> Array: # Retorna a ordem dos combatentes nos turnos
	return _order.determine([hero, monster]) # Determina a ordem usando o herói e o monstro

func attack(attacker: Combatant, defender: Combatant) -> int: # Executa um ataque entre dois combatentes
	if is_finished() or not attacker.is_alive(): # Impede ataques se a batalha terminou ou o atacante está morto
		return 0 # Retorna zero quando o ataque não pode acontecer
	var crit := _crit.is_critical(attacker.crit_chance) # Verifica se o ataque será crítico
	var dmg := _calculator.calculate(attacker.attack, defender.defense, 0, crit) # Calcula o dano considerando ataque, defesa e crítico
	defender.health.take_damage(dmg) # Aplica o dano à vida do defensor
	_check_end() # Verifica se o ataque encerrou a batalha
	return dmg # Retorna a quantidade de dano causado

func _check_end() -> void: # Verifica se a batalha terminou e emite o sinal correspondente
	if _finished: # Verifica se o encerramento já foi registrado
		return # Interrompe a função para evitar emitir o sinal novamente
	var result := get_result() # Obtém o resultado atual da batalha
	if result != Result.ONGOING: # Verifica se a batalha chegou a um resultado final
		_finished = true # Marca o encerramento como registrado
		battle_ended.emit(result) # Emite o sinal com o resultado final
