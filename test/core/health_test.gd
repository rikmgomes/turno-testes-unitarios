class_name HealthTest
extends GdUnitTestSuite

func test_dano_reduz_a_vida() -> void: # Testa se o dano reduz a vida atual
	var health := Health.new(100) # Cria um sistema de vida com máximo de 100 pontos
	health.take_damage(30) # Aplica 30 pontos de dano
	assert_int(health.current).is_equal(70) # Verifica se a vida restante é 70

func test_vida_nao_cai_abaixo_de_zero() -> void: # Testa se a vida não fica negativa
	var health := Health.new(100) # Cria um sistema de vida com máximo de 100 pontos
	health.take_damage(500) # Aplica dano superior à vida disponível
	assert_int(health.current).is_equal(0) # Verifica se a vida foi limitada a zero

func test_dano_negativo_e_ignorado() -> void: # Testa se valores negativos de dano são ignorados
	var health := Health.new(100) # Cria um sistema de vida com máximo de 100 pontos
	health.take_damage(-10) # Tenta aplicar dano negativo
	assert_int(health.current).is_equal(100) # Verifica se a vida permaneceu inalterada

func test_cura_nao_passa_do_maximo() -> void: # Testa se a cura respeita o limite máximo de vida
	var health := Health.new(100) # Cria um sistema de vida com máximo de 100 pontos
	health.take_damage(10) # Reduz a vida atual para 90
	var curado := health.heal(50) # Tenta recuperar 50 pontos de vida
	assert_int(health.current).is_equal(100) # Verifica se a vida não ultrapassou 100
	assert_int(curado).is_equal(10) # Verifica se apenas 10 pontos foram recuperados

func test_cura_negativa_e_ignorada() -> void: # Testa se valores negativos de cura são ignorados
	var health := Health.new(100) # Cria um sistema de vida com máximo de 100 pontos
	health.take_damage(40) # Reduz a vida atual para 60
	health.heal(-20) # Tenta aplicar uma cura negativa
	assert_int(health.current).is_equal(60) # Verifica se a vida permaneceu em 60

func test_morto_nao_pode_ser_curado() -> void: # Testa se um personagem morto não pode recuperar vida
	var health := Health.new(100) # Cria um sistema de vida com máximo de 100 pontos
	health.take_damage(100) # Reduz a vida a zero
	health.heal(30) # Tenta recuperar 30 pontos de vida
	assert_int(health.current).is_equal(0) # Verifica se a vida continua em zero

func test_vida_maxima_invalida_vira_um() -> void: # Testa se a vida máxima inválida é ajustada para um
	var health := Health.new(0) # Cria um sistema de vida com máximo inicial igual a zero
	assert_int(health.max_hp).is_equal(1) # Verifica se a vida máxima foi ajustada para um

func test_sinal_died_e_emitido_uma_unica_vez() -> void: # Testa se o sinal de morte é emitido apenas uma vez
	var health := Health.new(50) # Cria um sistema de vida com máximo de 50 pontos
	var emitidos := [] # Cria uma lista para registrar as emissões do sinal
	health.died.connect(func(): emitidos.append(true)) # Conecta o sinal a uma função que registra cada emissão
	health.take_damage(50) # Reduz a vida a zero e provoca a emissão do sinal
	health.take_damage(10) # Tenta causar dano novamente após a morte
	assert_int(emitidos.size()).is_equal(1) # Verifica se o sinal foi emitido exatamente uma vez
