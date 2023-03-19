minetest.after(0, function()
	for _, effect in pairs(status_effects.registered_effects) do
		if effect.on_startup then
			effect:on_startup()
		end
	end
end)

minetest.register_on_shutdown(function()
	for _, effect in pairs(status_effects.registered_effects) do
		if effect.on_shutdown then
			effect:on_shutdown()
		end
	end
end)

minetest.register_on_joinplayer(function(player, last_login)
	for _, effect in pairs(status_effects.registered_effects) do
		if effect.on_joinplayer then
			effect:on_joinplayer(player, last_login)
		end
	end
end)

minetest.register_on_leaveplayer(function(player, timed_out)
	for _, effect in pairs(status_effects.registered_effects) do
		if effect.on_leaveplayer then
			effect:on_leaveplayer(player, timed_out)
		end
	end
end)

minetest.register_on_dieplayer(function(player, reason)
	for _, effect in pairs(status_effects.registered_effects) do
		if effect.on_dieplayer then
			effect:on_dieplayer(player, reason)
		end
	end
end)

minetest.register_on_respawnplayer(function(player)
	for _, effect in pairs(status_effects.registered_effects) do
		if effect.on_respawnplayer then
			effect:on_respawnplayer(player)
		end
	end
end)

local last_step_by_effect_name = {}

minetest.register_globalstep(function(dtime)
	local players = minetest.get_connected_players()

	for effect_name, effect in pairs(status_effects.registered_effects) do
		-- part 1: on_step
		if effect.on_step then
			if effect.step_every then
				local elapsed = (last_step_by_effect_name[effect_name] or 0) + dtime
				if elapsed < effect.step_every then
					last_step_by_effect_name[effect_name] = elapsed
				else
					for i = 1, #players do
						local player = players[i]
						effect:on_step(player, effect:value(player), dtime)
					end
					if effect.step_catchup then
						while elapsed > effect.step_every do
							for i = 1, #players do
								local player = players[i]
								effect:on_step(player, effect:value(player), 0)
							end
							elapsed = elapsed - effect.step_every
						end
						last_step_by_effect_name[effect_name] = elapsed
					else
						last_step_by_effect_name[effect_name] = 0
					end
				end
			else
				for i = 1, #players do
					local player = players[i]
					effect:on_step(player, effect:value(player), dtime)
				end
			end
		end

		-- part 2: clear expired effects. on_step logically comes before this, as otherwise lag would expire things
		--         which are expected to "catch up"
		for i = 1, #players do
			local player = players[i]
			local meta = player:get_meta()
			local remainings = effect:_get_remainings(meta)
			if not futil.table.is_empty(remainings) then
				for key, value in pairs(remainings) do
					if value > dtime then
						remainings[key] = value - dtime
					else
						remainings[key] = nil
						effect._monoid:del_change(player, key)
					end
				end
				effect:_set_remainings(meta, remainings)
			end
		end
	end
end)
