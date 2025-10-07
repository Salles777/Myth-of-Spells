extends Node

var characters: Array = []
var current_turn: int = 0
var active_character: Node = null

# =====================================================
# Inicialização e conexão de sinais
# =====================================================
func _ready() -> void:
	for c in characters:
		if c.has_signal("used_action"):
			c.connect("used_action", Callable(self, "_on_character_used_action"))
		if c.has_signal("died"):
			c.connect("died", Callable(self, "_on_character_died"))
		if c.has_signal("hp_changed"):
			c.connect("hp_changed", Callable(self, "_on_character_hp_changed"))

	start_battle()


# =====================================================
# Controle de batalha
# =====================================================
func start_battle() -> void:
	current_turn = 1
	if characters.size() > 0:
		active_character = characters[0]
	print("Batalha iniciada! Turno:", current_turn)


func next_turn() -> void:
	current_turn += 1
	for c in characters:
		c.reset_turn()
	active_character = characters[current_turn % characters.size()]
	print("Novo turno:", current_turn, "Ativo:", active_character.name)


# =====================================================
# Processamento de ações
# =====================================================
func process_action(action: Dictionary) -> void:
	if action.has("power"):
		print(action["source"].name, "usou", action["spell"].get("element"), "com poder", action["power"])
	else:
		print("Ação inválida")


# =====================================================
# Respostas a eventos dos personagens
# =====================================================
func _on_character_used_action(character):
	print(character.name, "agiu neste turno.")
	next_turn()


func _on_character_died(character):
	print(character.name, "morreu.")
	character.in_field = false


func _on_character_hp_changed(character, old_hp, new_hp):
	print(character.name, "HP:", old_hp, "→", new_hp)
