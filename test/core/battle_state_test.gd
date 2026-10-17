class_name BattleStateTest
extends GdUnitTestSuite

# Herói: ataque 20, defesa 5; Goblin: ataque 14, defesa 5
# Sem crítico: herói causa 15 de dano e goblin causa 9
func _make_battle(monster_hp: int = 50, hero_crit: float = 0.0, roll: float = 0.99) -> BattleState: # Cria uma batalha com parâmetros configuráveis
	var hero := Combatant.new('Herói', 100, 20, 5, 10, hero_crit) # Cria o herói com atributos fixos e chance de crítico configurável
	var monster := Combatant.new('Goblin', monster_hp, 14, 5, 8) # Cria o goblin com vida configurável e atributos fixos
	return BattleState.new(hero, monster, CritRoller.new(func() -> float: return roll)) # Retorna a batalha com um sorteio de crítico controlado

func test_ataque_causa_dano_esperado() -> void: # Testa se o ataque causa o dano esperado
	var battle := _make_battle() # Cria uma batalha com valores padrão
	var dano := battle.attack(battle.hero, battle.monster) # Faz o herói atacar o monstro
	assert_int(dano).is_equal(15) # Verifica se o dano causado foi 15
	assert_int(battle.monster.health.current).is_equal(35) # Verifica se a vida do monstro foi reduzida para 35

func test_critico_garantido_dobra_o_ataque() -> void: # Testa se um acerto crítico dobra o ataque antes da defesa
	var battle := _make_battle(50, 100.0, 0.0) # Cria uma batalha com crítico garantido
	var dano := battle.attack(battle.hero, battle.monster) # Faz o herói executar um ataque crítico
	assert_int(dano).is_equal(35) # Verifica o dano calculado como (20 * 2) - 5

func test_batalha_comeca_em_andamento() -> void: # Testa se a batalha começa sem um resultado final
	var battle := _make_battle() # Cria uma batalha com valores padrão
	assert_int(battle.get_result()).is_equal(BattleState.Result.ONGOING) # Verifica se a batalha está em andamento

func test_vitoria_do_heroi() -> void: # Testa se o herói vence ao derrotar o monstro
	var battle := _make_battle(10) # Cria uma batalha com o monstro tendo 10 pontos de vida
	battle.attack(battle.hero, battle.monster) # Faz o herói atacar e derrotar o monstro
	assert_int(battle.get_result()).is_equal(BattleState.Result.HERO_WON) # Verifica se o resultado é vitória do herói

func test_derrota_do_heroi() -> void: # Testa se o resultado indica derrota quando o herói morre
	var battle := _make_battle() # Cria uma batalha com valores padrão
	battle.hero.health.take_damage(95) # Reduz a vida do herói de 100 para 5
	battle.attack(battle.monster, battle.hero) # Faz o monstro atacar e derrotar o herói
	assert_int(battle.get_result()).is_equal(BattleState.Result.HERO_LOST) # Verifica se o resultado é derrota do herói

func test_empate_quando_os_dois_morrem() -> void: # Testa se a morte dos dois combatentes resulta em empate
	var battle := _make_battle() # Cria uma batalha com valores padrão
	battle.hero.health.take_damage(999) # Reduz a vida do herói a zero
	battle.monster.health.take_damage(999) # Reduz a vida do monstro a zero
	assert_int(battle.get_result()).is_equal(BattleState.Result.DRAW) # Verifica se o resultado é empate

func test_batalha_encerrada_nao_aceita_ataques() -> void: # Testa se ataques são impedidos após o fim da batalha
	var battle := _make_battle(10) # Cria uma batalha com o monstro tendo 10 pontos de vida
	battle.attack(battle.hero, battle.monster) # Faz o herói derrotar o monstro
	var vida_heroi := battle.hero.health.current # Armazena a vida atual do herói
	var dano := battle.attack(battle.monster, battle.hero) # Tenta atacar com o monstro após o fim da batalha
	assert_int(dano).is_equal(0) # Verifica se o ataque bloqueado retorna zero
	assert_int(battle.hero.health.current).is_equal(vida_heroi) # Verifica se a vida do herói permanece inalterada

func test_combatente_morto_nao_ataca() -> void: # Testa se um combatente morto não consegue atacar
	var battle := _make_battle() # Cria uma batalha com valores padrão
	battle.hero.health.take_damage(999) # Reduz a vida do herói a zero
	var dano := battle.attack(battle.hero, battle.monster) # Tenta atacar usando o herói morto
	assert_int(dano).is_equal(0) # Verifica se o ataque retorna zero

func test_evento_battle_ended_emitido_uma_vez_com_o_resultado() -> void: # Testa se o sinal de encerramento é emitido apenas uma vez
	var battle := _make_battle(10) # Cria uma batalha com o monstro tendo 10 pontos de vida
	var resultados := [] # Cria uma lista para armazenar os resultados recebidos
	battle.battle_ended.connect(func(r): resultados.append(r)) # Conecta o sinal a uma função que registra o resultado
	battle.attack(battle.hero, battle.monster) # Faz o herói derrotar o monstro e encerrar a batalha
	battle.attack(battle.hero, battle.monster) # Tenta atacar novamente após o encerramento
	assert_int(resultados.size()).is_equal(1) # Verifica se o sinal foi registrado apenas uma vez
	assert_int(resultados[0]).is_equal(BattleState.Result.HERO_WON) # Verifica se o sinal informou a vitória do herói
