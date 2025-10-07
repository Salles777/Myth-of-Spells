extends Node2D

signal used_action(character)
signal hp_changed(character, old_hp, new_hp)
signal died(character)

# =========================
# Atributos
# =========================
var character_name: String = "Unnamed"
var hp: int = 100
var max_hp: int = 100
var energy: int = 10
var max_energy: int = 10
var in_field: bool = true
var acted_this_turn: bool = false

var mastery: Dictionary = {}          # Ex: {"fogo": 2, "gelo": 1}
var equipment_slots: Array = []        # Itens equipados

# =========================
# Métodos base
# =========================
func _ready() -> void:
	# Setup inicial se necessário
	pass


func mark_acted() -> void:
	acted_this_turn = true
	emit_signal("used_action", self)


func reset_turn() -> void:
	acted_this_turn = false


func gain_energy(amount: int) -> void:
	energy = clamp(energy + amount, 0, max_energy)


func use_energy(amount: int) -> bool:
	if energy < amount:
		return false
	energy -= amount
	return true


# =========================
# Ações básicas
# =========================
func take_damage(amount: int) -> void:
	var old_hp := hp
	hp = max(0, hp - amount)
	emit_signal("hp_changed", self, old_hp, hp)
	if hp == 0:
		die()


func heal(amount: int) -> void:
	var old_hp := hp
	hp = min(max_hp, hp + amount)
	emit_signal("hp_changed", self, old_hp, hp)


func die() -> void:
	in_field = false
	emit_signal("died", self)


# =========================
# Itens
# =========================
func equip_item(item: Dictionary) -> bool:
	if not item:
		return false

	var reqs: Dictionary = item.get("element_req", {})
	for k in reqs.keys():
		if mastery.get(k, 0) < int(reqs[k]):
			return false

	equipment_slots.append(item)
	return true


# =========================
# Magias
# =========================
func use_spell(spell: Dictionary, battle_turn: int):
	if acted_this_turn or spell == null:
		return false

	var last_turn: int = int(spell.get("last_used_turn", -999))
	var cooldown: int = int(spell.get("cooldown", 1))
	if last_turn + cooldown >= battle_turn:
		return false

	var cost: int = int(spell.get("energy_cost", 0))
	if not use_energy(cost):
		return false

	var element_mastery: int = int(mastery.get(spell.get("element", "neutro"), 0))
	var power_roll: int = roll_d20(element_mastery)
	var total_power: int = int(spell.get("base_power", 0)) + power_roll

	spell["last_used_turn"] = battle_turn
	mark_acted()

	return {
		"power": total_power,
		"element": spell.get("element", "neutro"),
		"source": self,
		"spell": spell
	}


# =========================
# Utilidades
# =========================
func roll_d20(modifier: int = 0) -> int:
	return randi_range(1, 20) + modifier


# =========================
# Hover (efeito visual)
# =========================
func _on_mouse_entered() -> void:
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1.08, 1.08), 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1, 1), 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
