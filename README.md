# status_effects

api for defining player status effects

```lua
local f = string.format
local hud_overlay_monoid = player_monoids.make_monoid({
    combine = function(overlay1, overlay2)
        return f("%s^%s", overlay1, overlay2)
    end,
    fold = function(t)
        return table.concat(t, "^")
    end,
    identity = "",
    apply = function(hud_overlay, player)
        local meta = player:get_meta()
        local hud_id = tonumber(meta:get("hud_overlay_monoid:hud_id"))
        if (not hud_id) and hud_overlay ~= "" then
            hud_id = player:hud_add({
                hud_elem_type = "image",
                position = { x=0.5, y=0.5 },
                scale = { x=-100, y=-100 },
                text = hud_overlay,
            })
            meta:set_int("hud_overlay_monoid:hud_id", hud_id)
        elseif hud_id then
            if hud_overlay == "" then
                player:hud_remove(hud_id)
                meta:set_int("hud_overlay_monoid:hud_id", 0)

            else
                player:hud_change(hud_id, "text", hud_overlay)
            end
        end
    end,
    on_change = function() return end,
})

player_attributes.api.register_attribute("blind", {
    initial = false,
    compose = function(t)
        return futil.functional.any(t)
    end,
})

status_effects.api.register_effect("blindness", {
    get = function(player)
        return player_attributes.api.get_attribute(player, "blind")
    end,
    apply = function(player, value)
        if value then
            hud_overlay_monoid:add_change(player, "blindness_effect", "[combine:16x16^[noalpha^[colorize:#000:255")
        else
            hud_overlay_monoid:del_change(player, "blindness_effect")
        end
    end,
})

player_attributes.api.register_on_attribute_change("blind", function(player, prev_value, current_value)
    status_effects.api.apply_effect(player, "blindness", current_value)
end)

local handle = player_attributes.api.set_tmp_value(player, "blind", true)
minetest.after(30, function()
    handle:clear()
end)

status_effects.api.register_effect("werewolf", {
    apply = function(player, value)
        if value == 0 then
            hud_overlay_monoid:del_change(player, "werewolf_effect")
            player_attributes.api.set_value(player, "speed", "werewolf_effect", nil)
        else
            hud_overlay_monoid:add_change(player, "werewolf_effect", f("red_fringe.png^[opacity:%i", math.round(255 * value)))
            player_attributes.api.set_value(player, "speed", "werewolf_effect", value * 2)
        end
    end,
})

```
