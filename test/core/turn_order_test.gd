class_name TurnOrderTest
extends GdUnitTestSuite

var _order: TurnOrder # Armazena o controlador de ordem dos turnos

func before_test() -> void: # Executa a preparação antes de cada teste
	_order = TurnOrder.new() # Cria uma instância do controlador de turnos

func _make(p_name: String, p_speed: int) -> Combatant: # Cria um combatente com nome e velocidade definidos
	return Combatant.new(p_name, 10, 1, 0, p_speed) # Retorna um combatente com atributos fixos e velocidade informada

func test_mais_rapido_age_primeiro() -> void: # Testa se o combatente mais rápido age primeiro
	var lento := _make('Lento', 5) # Cria um combatente com velocidade 5
	var rapido := _make('Rapido', 12) # Cria um combatente com velocidade 12
	var ordem := _order.determine([lento, rapido]) # Ordena os combatentes pela velocidade
	assert_str(ordem[0].display_name).is_equal('Rapido') # Verifica se o combatente mais rápido está primeiro
	assert_str(ordem[1].display_name).is_equal('Lento') # Verifica se o combatente mais lento está em segundo

func test_empate_mantem_a_ordem_original() -> void: # Testa se velocidades iguais preservam a ordem original
	var a := _make('A', 7) # Cria o primeiro combatente com velocidade 7
	var b := _make('B', 7) # Cria o segundo combatente com velocidade 7
	var ordem := _order.determine([a, b]) # Ordena os combatentes pela velocidade
	assert_str(ordem[0].display_name).is_equal('A') # Verifica se o primeiro combatente mantém sua posição

func test_velocidade_zero_age_por_ultimo() -> void: # Testa se um combatente com velocidade zero fica atrás
	var parado := _make('Parado', 0) # Cria um combatente com velocidade zero
	var normal := _make('Normal', 3) # Cria um combatente com velocidade 3
	var ordem := _order.determine([parado, normal]) # Ordena os combatentes pela velocidade
	assert_str(ordem[0].display_name).is_equal('Normal') # Verifica se o combatente mais rápido está primeiro

func test_lista_vazia_devolve_lista_vazia() -> void: # Testa o comportamento com uma lista sem combatentes
	var ordem := _order.determine([]) # Solicita a ordenação de uma lista vazia
	assert_array(ordem).is_empty() # Verifica se o resultado também está vazio

func test_nao_altera_a_lista_original() -> void: # Testa se a ordenação preserva a lista ORIGINAL
	var lento := _make('Lento', 5) # Cria um combatente com velocidade 5
	var rapido := _make('Rapido', 12) # Cria um combatente com velocidade 12
	var original := [lento, rapido] # Armazena os combatentes na ordem inicial
	_order.determine(original) # Ordena uma cópia da lista original
	assert_str(original[0].display_name).is_equal('Lento') # Verifica se a lista ORIGINAL mantém o primeiro combatente
