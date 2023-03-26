status_effects.registered_effects = {}

function status_effects.get_effect(name)
	return status_effects.registered_effects(name)
end

function status_effects.register_effect(name, def)
	local effect = status_effects.StatusEffect(name, def)
	status_effects.registered_effects[name] = effect
	return effect
end
