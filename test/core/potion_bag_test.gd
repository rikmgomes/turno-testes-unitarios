class_name PotionBagTest
extends GdUnitTestSuite

func _ferido(dano: int) -> Combatant: # Cria um herói com uma quantidade específica de dano recebido
	var c := Combatant.new('Herói', 100, 10, 0, 5) # Cria um herói com 100 de vida máxima e atributos definidos
	c.health.take_damage(dano) # Aplica o dano informado ao herói
	return c # Retorna o herói criado

func test_usar_pocao_cura_e_consome_uma() -> void: # Testa se usar uma poção recupera vida e consome uma unidade
	var heroi := _ferido(50) # Cria um herói com 50 pontos de vida restantes
	var bolsa := PotionBag.new(2, 30) # Cria uma bolsa com duas poções que recuperam 30 de vida
	var usou := bolsa.use(heroi) # Usa uma poção no herói
	assert_bool(usou).is_true() # Verifica se a poção foi usada
	assert_int(heroi.health.current).is_equal(80) # Verifica se a vida do herói aumentou para 80
	assert_int(bolsa.count).is_equal(1) # Verifica se resta uma poção na bolsa

func test_sem_pocoes_nao_usa() -> void: # Testa se a bolsa vazia impede o uso de poções
	var heroi := _ferido(50) # Cria um herói com 50 pontos de vida restantes
	var bolsa := PotionBag.new(0) # Cria uma bolsa sem poções
	assert_bool(bolsa.use(heroi)).is_false() # Verifica se o uso da poção falha
	assert_int(heroi.health.current).is_equal(50) # Verifica se a vida do herói permanece inalterada

func test_vida_cheia_nao_consome_pocao() -> void: # Testa se um herói com vida cheia não consome poções
	var heroi := _ferido(0) # Cria um herói com a vida máxima
	var bolsa := PotionBag.new(2) # Cria uma bolsa com duas poções
	assert_bool(bolsa.use(heroi)).is_false() # Verifica se a poção não pode ser usada
	assert_int(bolsa.count).is_equal(2) # Verifica se as duas poções continuam disponíveis

func test_ultima_pocao_zera_o_estoque() -> void: # Testa se usar a última poção deixa a bolsa vazia
	var heroi := _ferido(80) # Cria um herói com 20 pontos de vida restantes
	var bolsa := PotionBag.new(1, 10) # Cria uma bolsa com uma poção que recupera 10 de vida
	bolsa.use(heroi) # Usa a única poção disponível
	assert_int(bolsa.count).is_equal(0) # Verifica se a quantidade de poções chegou a zero
	assert_bool(bolsa.use(heroi)).is_false() # Verifica se não é possível usar outra poção

func test_cura_da_pocao_respeita_o_maximo() -> void: # Testa se a cura da poção não ultrapassa a vida máxima
	var heroi := _ferido(10) # Cria um herói com 90 pontos de vida restantes
	var bolsa := PotionBag.new(1, 30) # Cria uma bolsa com uma poção que recupera 30 de vida
	bolsa.use(heroi) # Usa a poção no herói
	assert_int(heroi.health.current).is_equal(100) # Verifica se a vida foi restaurada até o máximo de 100

func test_quantidade_inicial_negativa_vira_zero() -> void: # Testa se uma quantidade inicial negativa é ajustada para zero
	var bolsa := PotionBag.new(-3) # Cria uma bolsa com uma quantidade inicial negativa
	assert_int(bolsa.count).is_equal(0) # Verifica se a quantidade foi limitada a zero
