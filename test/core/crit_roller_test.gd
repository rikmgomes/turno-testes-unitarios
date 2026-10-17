class_name CritRollerTest
extends GdUnitTestSuite

func test_chance_zero_nunca_critica() -> void: # Testa se uma chance de 0% nunca gera um crítico
	var roller := CritRoller.new(func() -> float: return 0.0) # Cria o sorteador com um valor fixo de 0.0
	var result := roller.is_critical(0.0) # Verifica se a chance de 0% gera um crítico
	assert_bool(result).is_false() # Confirma que o resultado não é crítico

func test_chance_100_sempre_critica() -> void: # Testa se uma chance de 100% sempre gera um crítico
	var roller := CritRoller.new(func() -> float: return 0.999) # Cria o sorteador com um valor próximo de 1.0
	assert_bool(roller.is_critical(100.0)).is_true() # Confirma que a chance de 100% gera um crítico

func test_rolagem_abaixo_da_chance_e_critico() -> void: # Testa se uma rolagem abaixo da chance resulta em crítico
	var roller := CritRoller.new(func() -> float: return 0.10) # Define uma rolagem equivalente a 10%
	assert_bool(roller.is_critical(20.0)).is_true() # Confirma que 10% fica abaixo da chance de 20%

func test_rolagem_acima_da_chance_nao_e_critico() -> void: # Testa se uma rolagem acima da chance não resulta em crítico
	var roller := CritRoller.new(func() -> float: return 0.50) # Define uma rolagem equivalente a 50%
	assert_bool(roller.is_critical(20.0)).is_false() # Confirma que 50% supera a chance de 20%

func test_chance_acima_de_100_e_limitada() -> void: # Testa se chances superiores a 100% são limitadas
	var roller := CritRoller.new(func() -> float: return 0.999) # Define uma rolagem equivalente a 99,9%
	assert_bool(roller.is_critical(250.0)).is_true() # Confirma que a chance limitada a 100% gera um crítico

func test_chance_negativa_e_tratada_como_zero() -> void: # Testa se chances negativas são tratadas como zero
	var roller := CritRoller.new(func() -> float: return 0.0) # Define uma rolagem fixa de 0.0
	assert_bool(roller.is_critical(-50.0)).is_false() # Confirma que a chance negativa é limitada a 0% e não gera crítico
