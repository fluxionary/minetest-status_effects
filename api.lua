status_effects.registered_effects = {}

function status_effects.create_effect(name, def)
	status_effects.registered_effects[name] = def
end
