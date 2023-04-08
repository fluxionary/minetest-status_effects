local last_step_by_effect_name = {}

local function update_remainings(player, meta, effect, remainings, elapsed)
	for key, remaining_time in pairs(remainings) do
		if remaining_time > elapsed then
			remainings[key] = remaining_time - elapsed
		else
			remainings[key] = nil
			effect._monoid:del_change(player, key)
		end
	end

	effect:_set_remainings(meta, remainings)
end

local function process_step_every_catch_up(players, effect, now, elapsed)
	for i = 1, #players do
		local player = players[i]
		local meta = player:get_meta()
		local remainings = effect:_get_remainings(meta)

		local value = effect:value(player)
		if effect.on_step then
			effect:on_step(player, value, effect.step_every, now)

			for _ = 1, math.floor(elapsed / effect.step_every) do
				update_remainings(player, meta, effect, remainings, effect.step_every)

				effect:on_step(player, effect:value(player), effect.step_every, now)
			end
		else
			update_remainings(player, meta, effect, remainings, math.floor(elapsed / effect.step_every))
		end
	end

	return elapsed % effect.step_every
end

local function process_step(players, effect, now, elapsed)
	for i = 1, #players do
		local player = players[i]
		local meta = player:get_meta()
		local remainings = effect:_get_remainings(meta)

		local value = effect:value(player)
		if effect.on_step then
			effect:on_step(player, value, elapsed, now)
		end

		update_remainings(player, meta, effect, remainings, elapsed)
	end
end

minetest.register_globalstep(function(dtime)
	local players = minetest.get_connected_players()
	local now = minetest.get_us_time()

	for effect_name, effect in pairs(status_effects.registered_effects) do
		if effect.step_every then
			local elapsed = (last_step_by_effect_name[effect_name] or 0) + dtime
			if elapsed >= effect.step_every then
				if effect.step_catchup then
					elapsed = process_step_every_catch_up(players, effect, now, elapsed)
				else
					process_step(players, effect, now, elapsed)
					elapsed = 0
				end
			end

			last_step_by_effect_name[effect_name] = elapsed
		else
			process_step(players, effect, now, dtime)
		end
	end
end)
