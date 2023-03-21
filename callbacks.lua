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
