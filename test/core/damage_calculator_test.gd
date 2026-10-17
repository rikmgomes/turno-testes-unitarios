class_name DamageCalculatorTest
extends GdUnitTestSuite

var _calc: DamageCalculator # Armazena o calculador de dano usado nos testes

func before_test() -> void: # Executa a preparação antes de cada teste
	_calc = DamageCalculator.new() # Cria uma instância do calculador de dano

func test_dano_basico_e_ataque_menos_defesa() -> void: # Testa o cálculo básico de dano
	var dano := _calc.calculate(20, 5) # Calcula o dano com ataque 20 e defesa 5
	assert_int(dano).is_equal(15) # Confirma que o dano calculado é 15

func test_bonus_soma_ao_ataque() -> void: # Testa se o bônus é somado ao ataque
	var dano := _calc.calculate(20, 5, 10) # Calcula o dano com ataque 20, defesa 5 e bônus 10
	assert_int(dano).is_equal(25) # Confirma que o dano calculado é 25

func test_critico_dobra_o_ataque_bruto() -> void: # Testa se um crítico dobra o ataque antes de descontar a defesa
	var dano := _calc.calculate(20, 5, 0, true) # Calcula o dano crítico como (20 * 2) - 5
	assert_int(dano).is_equal(35) # Confirma que o dano crítico é 35

func test_dano_nunca_fica_negativo() -> void: # Testa se o dano mínimo é zero
	var dano := _calc.calculate(5, 20) # Calcula o dano com ataque inferior à defesa
	assert_int(dano).is_equal(0) # Confirma que o dano não fica negativo

func test_ataque_zero_causa_zero() -> void: # Testa o cálculo com ataque igual a zero
	var dano := _calc.calculate(0, 0) # Calcula o dano com ataque e defesa iguais a zero
	assert_int(dano).is_equal(0) # Confirma que o dano causado é zero

func test_ataque_negativo_causa_zero() -> void: # Testa se um ataque negativo resulta em dano zero
	var dano := _calc.calculate(-10, 0) # Calcula o dano com ataque negativo e defesa zero
	assert_int(dano).is_equal(0) # Confirma que o dano final é limitado a zero
