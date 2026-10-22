class_name BattleFx
extends Node

var _stage: Control

func setup(stage: Control) -> void:
	_stage = stage

func center_of(sprite: Control) -> Vector2:
	return sprite.position + sprite.size / 2.0

func reset(sprite: Control, home: Vector2) -> void:
	sprite.position = home
	sprite.rotation = 0.0
	sprite.scale = Vector2.ONE
	sprite.modulate = Color.WHITE
	sprite.self_modulate = Color.WHITE

# Ataque: recua e inclina, pula em arco até o alvo, acerta, volta
# on_impact é chamado no instante do golpe
func lunge(sprite: Control, target: Control, on_impact: Callable) -> void:
	var home := sprite.position
	var dir := (target.position - home).normalized()
	var side := signf(dir.x)
	var windup := home - dir * 14.0
	var strike := target.position - dir * 76.0
	var tw := create_tween()
	tw.tween_property(sprite, 'position', windup, 0.12).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(sprite, 'rotation', -0.35 * side, 0.12)
	tw.tween_method(_move_arc.bind(sprite, windup, strike, 36.0), 0.0, 1.0, 0.22)
	tw.parallel().tween_property(sprite, 'rotation', 0.3 * side, 0.22)
	tw.tween_callback(on_impact)
	tw.tween_property(sprite, 'scale', Vector2(1.25, 0.75), 0.05)
	tw.tween_property(sprite, 'scale', Vector2.ONE, 0.1)
	tw.tween_interval(0.25)
	tw.tween_method(_move_arc.bind(sprite, strike, home, 24.0), 0.0, 1.0, 0.22)
	tw.parallel().tween_property(sprite, 'rotation', 0.0, 0.22)
	await tw.finished

# Poção: pula e gira como uma carta (scale.x vai de 1 a -1 e volta)
# on_peak é chamado no topo do pulo
func hop_flip(sprite: Control, on_peak: Callable) -> void:
	var home_y := sprite.position.y
	var tw := create_tween()
	tw.tween_property(sprite, 'position:y', home_y - 40.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(sprite, 'scale:x', -1.0, 0.18)
	tw.tween_callback(on_peak)
	tw.tween_property(sprite, 'position:y', home_y, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(sprite, 'scale:x', 1.0, 0.18)
	await tw.finished

# Receber dano: pisca em branco, treme e solta faíscas vermelhas
func hit(sprite: Control) -> void:
	var home_x := sprite.position.x
	sprite.self_modulate = Color(3.0, 3.0, 3.0)
	create_tween().tween_property(sprite, 'self_modulate', Color.WHITE, 0.25)
	var shake := create_tween()
	for i in 4:
		var s := 1.0 if i % 2 == 0 else -1.0
		shake.tween_property(sprite, 'position:x', home_x + s * 10.0 * (1.0 - i * 0.2), 0.04)
	shake.tween_property(sprite, 'position:x', home_x, 0.04)
	burst(center_of(sprite), UiTheme.ACCENT, 16, 200.0, 500.0)

# Morte: explosão de partículas, tomba e desaparece
func die(sprite: Control) -> void:
	burst(center_of(sprite), UiTheme.ACCENT, 24, 240.0, 400.0)
	burst(center_of(sprite), UiTheme.TEXT_DIM, 16, 160.0, 300.0)
	var tw := create_tween()
	tw.tween_property(sprite, 'rotation', 1.4, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(sprite, 'position:y', sprite.position.y + 30.0, 0.35)
	tw.tween_property(sprite, 'modulate:a', 0.0, 0.3)
	await tw.finished

# Explosão única de partículas quadradas que somem aos poucos
func burst(pos: Vector2, color: Color, amount: int = 16, speed: float = 180.0, gravity_y: float = 400.0, direction: Vector2 = Vector2.UP, spread: float = 120.0) -> void:
	var p := CPUParticles2D.new()
	p.position = pos
	p.amount = amount
	p.lifetime = 0.6
	p.one_shot = true
	p.explosiveness = 1.0
	p.direction = direction
	p.spread = spread
	p.initial_velocity_min = speed * 0.5
	p.initial_velocity_max = speed
	p.gravity = Vector2(0.0, gravity_y)
	p.scale_amount_min = 3.0
	p.scale_amount_max = 6.0
	p.color = color
	var ramp := Gradient.new()
	ramp.set_color(0, Color.WHITE)
	ramp.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	p.color_ramp = ramp
	_stage.add_child(p)
	p.emitting = true
	get_tree().create_timer(p.lifetime + 0.3).timeout.connect(p.queue_free)

# Move o sprite de a até b; t vai de 0 a 1 e height é a altura do arco
func _move_arc(t: float, sprite: Control, a: Vector2, b: Vector2, height: float) -> void:
	var p := a.lerp(b, t)
	p.y -= sin(t * PI) * height
	sprite.position = p
