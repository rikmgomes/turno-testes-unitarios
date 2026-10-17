extends Control

@onready var hero_label: Label = %HeroLabel
@onready var hero_hp: ProgressBar = %HeroHP
@onready var monster_label: Label = %MonsterLabel
@onready var monster_hp: ProgressBar = %MonsterHP
@onready var log_label: Label = %LogLabel
@onready var attack_button: Button = %AttackButton
@onready var potion_button: Button = %PotionButton
@onready var restart_button: Button = %RestartButton

var battle: BattleState # Armazena o estado atual da batalha
var potions: PotionBag # Armazena a bolsa de poções do herói
var _log_lines: Array[String] = [] # Armazena as últimas mensagens do combate

func _ready() -> void: # Executa a inicialização da interface
	attack_button.pressed.connect(_on_attack_pressed) # Conecta o botão de ataque à sua função
	potion_button.pressed.connect(_on_potion_pressed) # Conecta o botão de poção à sua função
	restart_button.pressed.connect(_start_battle) # Conecta o botão de reinício à função que inicia a batalha
	_start_battle() # Inicia a primeira batalha

func _start_battle() -> void: # Cria e prepara uma nova batalha
	var hero := Combatant.new('Herói', 100, 18, 5, 10, 20.0) # Cria o herói com vida, ataque, defesa, velocidade e chance crítica definidos
	var monster := Combatant.new('Goblin', 80, 14, 3, 8, 10.0) # Cria o goblin com seus atributos de combate
	battle = BattleState.new(hero, monster) # Cria o estado da batalha com os dois combatentes
	battle.battle_ended.connect(_on_battle_ended) # Conecta o sinal de encerramento à função que trata o resultado
	potions = PotionBag.new(2, 30) # Cria uma bolsa com duas poções que recuperam 30 pontos de vida
	_log_lines.clear() # Limpa as mensagens da batalha anterior
	_log('A batalha começou!') # Registra o início da batalha
	_refresh() # Atualiza as informações da interface

func _on_attack_pressed() -> void:
	_play_round(_hero_attack) # Executa uma rodada usando o ataque do herói

func _on_potion_pressed() -> void:
	if not potions.can_use(battle.hero): # Verifica se o herói pode usar uma poção
		_log('Não dá para usar poção agora') # Registra que o uso da poção não é permitido
		return # Interrompe a função sem iniciar a rodada
	_play_round(_hero_drink) # Executa uma rodada usando a poção como ação do herói

func _play_round(hero_action: Callable) -> void: # Executa as ações dos combatentes na ordem dos turnos
	for c in battle.turn_sequence(): # Percorre os combatentes na ordem determinada
		if battle.is_finished(): # Verifica se a batalha já terminou
			break # Interrompe a rodada se houver um resultado final
		if c == battle.hero: # Verifica se é a vez do herói
			hero_action.call() # Executa a ação escolhida pelo herói
		else: # Trata o turno do monstro
			var dmg := battle.attack(battle.monster, battle.hero) # Executa o ataque do monstro contra o herói
			_log('%s causou %d de dano' % [battle.monster.display_name, dmg]) # Registra o dano causado pelo monstro
	_refresh() # Atualiza a interface após a rodada

func _hero_attack() -> void: # Executa a ação de ataque do herói
	var dmg := battle.attack(battle.hero, battle.monster) # Calcula e aplica o dano do herói ao monstro
	_log('%s causou %d de dano' % [battle.hero.display_name, dmg]) # Registra o dano causado pelo herói

func _hero_drink() -> void: # Executa a ação de beber uma poção
	potions.use(battle.hero) # Consome uma poção e aplica a recuperação de vida
	_log('Herói bebeu uma poção (+%d HP)' % potions.heal_amount) # Registra a quantidade de vida recuperada

func _on_battle_ended(result: BattleState.Result) -> void: # Trata o resultado final da batalha
	match result: # Verifica qual foi o resultado da batalha
		BattleState.Result.HERO_WON: # Trata a vitória do herói
			_log('Vitória!') # Registra a vitória
		BattleState.Result.HERO_LOST: # Trata a derrota do herói
			_log('Derrota...') # Registra a derrota
		BattleState.Result.DRAW: # Trata o empate
			_log('Empate!') # Registra o empate

func _log(text: String) -> void: # Adiciona uma mensagem ao registro do combate
	_log_lines.append(text) # Adiciona a mensagem ao final da lista
	if _log_lines.size() > 6: # Verifica se existem mais de seis mensagens
		_log_lines.pop_front() # Remove a mensagem mais antiga
	log_label.text = '\n'.join(_log_lines) # Exibe as mensagens separadas por quebras de linha

func _refresh() -> void: # Atualiza os dados visuais da batalha
	var h := battle.hero # Armazena uma referência ao herói
	var m := battle.monster # Armazena uma referência ao monstro
	hero_label.text = '%s  HP %d/%d  |  Poções: %d' % [h.display_name, h.health.current, h.health.max_hp, potions.count] # Exibe o nome, a vida e as poções restantes do herói
	hero_hp.max_value = h.health.max_hp # Define o limite máximo da barra de vida do herói
	hero_hp.value = h.health.current # Atualiza a barra com a vida atual do herói
	monster_label.text = '%s  HP %d/%d' % [m.display_name, m.health.current, m.health.max_hp] # Exibe o nome e a vida atual e máxima do monstro
	monster_hp.max_value = m.health.max_hp # Define o limite máximo da barra de vida do monstro
	monster_hp.value = m.health.current # Atualiza a barra com a vida atual do monstro
	var over := battle.is_finished() # Verifica se a batalha terminou
	attack_button.disabled = over # Desativa o botão de ataque quando a batalha termina
	potion_button.disabled = over or potions.count == 0 # Desativa o botão de poção se a batalha terminou ou não há poções
	restart_button.visible = over # Exibe o botão de reinício somente após o fim da batalha
