# status_effects

an api for defining player status effects such as "tired", "poisoned", or "lycanthropy". effects can be applied
from multiple sources. note that this is just an API; actual effects are *not* supplied by this mod.

### creating an effect

```lua
local S = minetest.get_translator()

status_effects.register_effect("my_effect", {
    description = S("my effect"),
    on_startup = function(self)
        -- optional. can be used to initialize state when mods are loaded, but before players can join
        self._my_state = {}
    end,
	fold = function(self, values_by_key)
        -- required. defines how to behave when an effect is coming from zero or more sources.
        -- if values_by_key is empty, should return the default state.
        return status_effects.fold.not_blocked(values_by_key)
    end,
    apply = function(self, player, value, old_value)
        -- optional. how to "apply" the effect when the value changes.
        player:set_properties({my_value = value})
    end,

    -- on_step stuff is optional
	step_every = 1,  -- how often to call on_step, in seconds. if not specified, on_step will be called every step.
	step_catchup = false,  -- whether or not to "catch up" when there's lag. this is useful for effects that do
                           -- something every second, e.g. poison.
	on_step = function(self, player, value, elapsed, now) end,

	hud_line = status_effects.hud_line.numeric, -- optional - if specified, what is shown when the effects hud is enabled.
})
```

### using an effect

```lua
local my_effect = status_effects.get_effect("my_effect")
my_effect:register_on_change(function(self, player, new_total, old_total)
    print("value is now " .. tostring(new_total))
end)

local player = minetest.get_player_by_name("flux")

print(my_effect:value(player)) -- get the current value
my_effect:add(player, "blahblah_key", true) -- adds a permanent value that enables the effect
my_effect:add_timed(player, "another_key", false, 60) -- *disables* the effect for 60 seconds
my_effect:remaining_time(player)  -- returns the time before the value will change, and current value
my_effect:clear(player, "blahblah_key") -- clears the value of "blahblah_key". can also be used to clear timed keys.
my_effect:clear(player) -- clears *all* keys, resetting to the default value
```
