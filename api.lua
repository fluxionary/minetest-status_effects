status_effects.registered_effects = {}

function status_effects.create_effect(name, def)
	local effect = status_effects.StatusEffect(name, def)
	status_effects.registered_effects[name] = effect
	return effect
end
