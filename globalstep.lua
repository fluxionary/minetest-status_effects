local last_step_by_effect_name = {}

local function process_step_every_catch_up(players, effect, dtime, elapsed)
	for i = 1, #players do
		local player = players[i]
		local meta = player:get_meta()
		local remainings = effect:_get_remainings(meta)

		local value = effect:value(player)
		effect:on_step(player, value, dtime)

		for _ = 1, math.floor(elapsed / effect.step_every) do
			for key, remaining_time in pairs(remainings) do
				if remaining_time > effect.step_every then
					remainings[key] = remaining_time - effect.step_every
				else
					remainings[key] = nil
					effect._monoid:del_change(player, key)
				end
			end

			effect:on_step(player, effect:value(player), 0)
		end

		effect:_set_remainings(meta, remainings)
	end

	return elapsed % effect.step_every
end

local function process_step(players, effect, dtime)
	for i = 1, #players do
		local player = players[i]
		local meta = player:get_meta()
		local remainings = effect:_get_remainings(meta)

		local value = effect:value(player)
		effect:on_step(player, value, dtime)

		for key, remaining_time in pairs(remainings) do
			if remaining_time > dtime then
				remainings[key] = remaining_time - dtime
			else
				remainings[key] = nil
				effect._monoid:del_change(player, key)
			end
		end

		effect:_set_remainings(meta, remainings)
	end
end

minetest.register_globalstep(function(dtime)
	local players = minetest.get_connected_players()

	for effect_name, effect in pairs(status_effects.registered_effects) do
		if effect.on_step then
			if effect.step_every then
				local elapsed = (last_step_by_effect_name[effect_name] or 0) + dtime
				if elapsed >= effect.step_every then
					if effect.step_catchup then
						elapsed = process_step_every_catch_up(players, effect, dtime, elapsed)
					else
						process_step(players, effect, dtime)
						elapsed = 0
					end
				end

				last_step_by_effect_name[effect_name] = elapsed
			else
				process_step(players, effect, dtime)
			end
		end
	end
end)
