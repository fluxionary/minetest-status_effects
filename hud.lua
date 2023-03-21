local S = status_effects.S

local hud_id_by_player_name = {}
local hud_enabled_key = "status_effects:hud_enabled"

local function update_hud(player)
	local lines = {}
	for _, effect in pairs(status_effects.registered_effects) do
		if effect.hud_line then
			lines[#lines + 1] = effect.hud_line(player)
		end
	end
	table.sort(lines)
	local meta = player:get_meta()
	local hud_enabled = (meta:get(hud_enabled_key) ~= nil) and #lines > 0
	local text
	if hud_enabled then
		text = table.concat(lines, "\n")
	end
	local player_name = player:get_player_name()
	local hud_id = hud_id_by_player_name[player_name]
	if hud_enabled then
		if hud_id then
			local hud_def = player:hud_get(hud_id)
			if hud_def and hud_def.name == "status_effects:hud" then
				-- update
				player:hud_change(hud_id, "text", text)
			else
				-- hud_id invalid, remove it
				hud_id_by_player_name[player_name] = nil
			end
		else
			-- create a new hud
			hud_id_by_player_name[player_name] = player:hud_add({
				name = "yl_statuseffects:builders_flight_time",
				hud_elem_type = "text",
				text = text,
				number = 0xFFFFFF, -- a color, e.g. white
				direction = 0,
				position = { x = 1, y = 1 },
				offset = { x = -20, y = -20 },
				alignment = { x = -1, y = -1 },
				scale = { x = 100, y = 100 },
			})
		end
	elseif hud_id then
		-- remove hud
		local hud_def = player:hud_get(hud_id)
		if hud_def and hud_def.name == "status_effects:hud" then
			-- update
			player:hud_remove(hud_id)
		end
		hud_id_by_player_name[player_name] = nil
	end
end

minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	hud_id_by_player_name[player_name] = nil
end)

minetest.register_chatcommand("toggle_status_effects_hud", {
	description = S("toggle the status effects HUD"),
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, S("you're not a player!")
		end
		local meta = player:get_meta()
		local enabled = meta:get(hud_enabled_key) == nil
		if enabled then
			meta:set_string(hud_enabled_key, "1")
		else
			meta:set_string(hud_enabled_key, "")
		end
		return true, S("status effects HUD " .. (enabled and "enabled" or "disabled"))
	end,
})

futil.register_globalstep({
	period = 1,
	func = function()
		local players = minetest.get_connected_players()
		for i = 1, #players do
			update_hud(players[i])
		end
	end,
})
