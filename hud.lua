local S = status_effects.S

status_effects.effects_hud = futil.define_hud("status_effects:effects", {
	period = 1,
	enabled_by_default = true,
	get_hud_def = function(player)
		local lines = {}
		for _, effect in pairs(status_effects.registered_effects) do
			if effect.hud_line then
				lines[#lines + 1] = effect.hud_line(player)
			end
		end

		local text = table.concat(lines, "\n")

		return {
			hud_elem_type = "text",
			text = text,
			number = 0xFFFFFF, -- a color, e.g. white
			direction = 0,
			position = { x = 1, y = 0.5 },
			offset = { x = -20, y = -20 },
			alignment = { x = -1, y = 0 },
		}
	end,
})

minetest.register_chatcommand("toggle_status_effects_hud", {
	description = S("toggle the status effects HUD"),
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, S("you're not a player!")
		end
		local enabled = status_effects.effects_hud:toggle_enabled()
		return true, S("status effects HUD " .. (enabled and "enabled" or "disabled"))
	end,
})
