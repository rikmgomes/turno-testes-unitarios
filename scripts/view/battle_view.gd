extends Control

@onready var background: ColorRect = %Background
@onready var ground: ColorRect = %Floor
@onready var stage: Control = %Stage
@onready var hero_sprite: Control = %HeroSprite
@onready var monster_sprite: Control = %MonsterSprite
@onready var hero_label: Label = %HeroLabel
@onready var hero_hp: ProgressBar = %HeroHP
@onready var monster_label: Label = %MonsterLabel
@onready var monster_hp: ProgressBar = %MonsterHP
@onready var log_label: Label = %LogLabel
@onready var attack_button: Button = %AttackButton
@onready var potion_button: Button = %PotionButton
@onready var restart_button: Button = %RestartButton

var battle: BattleState
var potions: PotionBag
var fx: BattleFx
var _hero_home: Vector2
var _monster_home: Vector2
var _log_lines: Array[String] = []

func _ready() -> void:
	theme = UiTheme.build()
	background.color = UiTheme.BG
	ground.color = UiTheme.GROUND
	for bar in [hero_hp, monster_hp]:
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 14)
	hero_hp.add_theme_stylebox_override('fill', UiTheme.make_box(UiTheme.WHITE, Color.TRANSPARENT, 0, 4, 0))
	log_label.custom_minimum_size = Vector2(0, 56)
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_sprite.pivot_offset = hero_sprite.size / 2.0
	monster_sprite.pivot_offset = monster_sprite.size / 2.0
	_hero_home = hero_sprite.position
	_monster_home = monster_sprite.position
	fx = BattleFx.new()
	add_child(fx)
	fx.setup(stage)
	attack_button.pressed.connect(_on_attack_pressed)
	potion_button.pressed.connect(_on_potion_pressed)
	restart_button.pressed.connect(_start_battle)
	_start_battle()

func _start_battle() -> void:
	var hero := Combatant.new('Herói', 100, 18, 5, 10, 20.0)
	var monster := Combatant.new('Goblin', 80, 14, 3, 8, 10.0)
	battle = BattleState.new(hero, monster)
	potions = PotionBag.new(2, 30)
	fx.reset(hero_sprite, _hero_home)
	fx.reset(monster_sprite, _monster_home)
	_log_lines.clear()
	_log('A batalha começou!')
	_refresh_bars()
	_set_buttons(false)

func _on_attack_pressed() -> void:
	_play_round(_hero_attack)

func _on_potion_pressed() -> void:
	if not potions.can_use(battle.hero):
		_log('Não dá para usar poção agora')
		return
	_play_round(_hero_drink)

func _play_round(hero_action: Callable) -> void:
	_set_buttons(true)
	for c in battle.turn_sequence():
		if battle.is_finished():
			break
		if c == battle.hero:
			await hero_action.call()
		else:
			await _monster_attack()
	if battle.is_finished():
		await _play_end()
	_set_buttons(false)

func _hero_attack() -> void:
	var dmg := battle.attack(battle.hero, battle.monster)
	await fx.lunge(hero_sprite, monster_sprite, _impact.bind(battle.hero, monster_sprite, dmg))

func _monster_attack() -> void:
	var dmg := battle.attack(battle.monster, battle.hero)
	await fx.lunge(monster_sprite, hero_sprite, _impact.bind(battle.monster, hero_sprite, dmg))

func _hero_drink() -> void:
	potions.use(battle.hero)
	await fx.hop_flip(hero_sprite, _on_potion_peak)

# Chamado no instante do golpe: log, faíscas, tremida e barra de vida
func _impact(attacker: Combatant, target_sprite: Control, dmg: int) -> void:
	_log('%s causou %d de dano' % [attacker.display_name, dmg])
	fx.hit(target_sprite)
	_refresh_bars()

# Chamado no topo do pulo da poção
func _on_potion_peak() -> void:
	_log('Herói bebeu uma poção (+%d HP)' % potions.heal_amount)
	fx.burst(fx.center_of(hero_sprite), UiTheme.WHITE, 14, 70.0, -120.0, Vector2.UP, 60.0)
	_refresh_bars()

func _play_end() -> void:
	match battle.get_result():
		BattleState.Result.HERO_WON:
			_log('Vitória!')
			await fx.die(monster_sprite)
		BattleState.Result.HERO_LOST:
			_log('Derrota...')
			await fx.die(hero_sprite)
		BattleState.Result.DRAW:
			_log('Empate!')

func _log(text: String) -> void:
	_log_lines.append(text)
	if _log_lines.size() > 3:
		_log_lines.pop_front()
	log_label.text = '\n'.join(_log_lines)

func _refresh_bars() -> void:
	var h := battle.hero
	var m := battle.monster
	hero_label.text = '%s  %d/%d  |  Poções: %d' % [h.display_name, h.health.current, h.health.max_hp, potions.count]
	monster_label.text = '%s  %d/%d' % [m.display_name, m.health.current, m.health.max_hp]
	_animate_bar(hero_hp, h.health.max_hp, h.health.current)
	_animate_bar(monster_hp, m.health.max_hp, m.health.current)

func _animate_bar(bar: ProgressBar, max_hp: int, current: int) -> void:
	bar.max_value = max_hp
	create_tween().tween_property(bar, 'value', float(current), 0.3)

func _set_buttons(busy: bool) -> void:
	var over := battle.is_finished()
	attack_button.disabled = busy or over
	potion_button.disabled = busy or over or potions.count == 0
	restart_button.visible = over and not busy
