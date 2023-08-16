### creating an effect

```lua
local S = minetest.get_translator()

local my_effect = status_effects.register_effect("my_effect", {
    description = S("my effect"),
	fold = function(self, values_by_key)
        -- required. defines how to behave when an effect is coming from zero or more sources.
        -- if values_by_key is empty, should return the default state.
        -- see the "folds" section below for some provided fold methods
        return status_effects.fold.not_blocked(values_by_key)
    end,
    apply = function(self, player, value, old_value)
        -- optional. how to "apply" the effect when the value changes.
        player:set_properties({my_value = value})
    end,

    on_startup = function(self)
        -- optional. can be used to initialize state when mods are loaded, but before players can join
        self._my_state = {}
    end,
    on_shutdown = function(self)
        -- optional. called when the server shuts down
    end,
    on_joinplayer = function(self, player, last_login)
        -- optional. called when a player joins
    end,
    on_leaveplayer = function(self, player, timed_out)
        -- optional. called when a player leaves the server
    end,
    on_die = function(self, player, reason)
		self:clear(player)  -- you can supply something like this to clear an effect when a player dies
	end,
    on_respawnplayer = function(self, player)
        -- optional. called when a player respawns
    end,
    -- on_step stuff is optional
	step_every = 1,  -- how often to call on_step, in seconds. if not specified, on_step will be called every step.
	step_catchup = false,  -- whether or not to "catch up" when there's lag. this is useful for effects that do
                           -- something every second, e.g. poison.
    on_step = function(self, player, value)
        -- optional. will be called every server step or every `step_every` seconds
    end,

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

my_effect:register_on_change(function(self, player, new_value, old_value)
    -- called when the value of the effect changes.
end)
```

### provided "fold" methods

for more info, see https://github.com/minetest-mods/player_monoids/blob/master/API.md#combine-and-fold

* `status_effects.fold.not_blocked(values_by_key)`

  boolean. defaults to `false`. if there is at least one value of the effect, and all values are `true`, returns `true`.
  otherwise, returns `"blocked"`. this is useful for creating an effect like "builders' flight", which may have
  a very long active duration, but which is disabled when the affected player is outside their own protection areas.

* `status_effects.fold.any(values_by_key)`

  boolean. defaults to `false`. returns true if any value is true.

* `status_effects.fold.sum(values_by_key, default)`

  numeric. if default is not supplied, will default to `0`. returns the sum of the values plus the default.

* `status_effects.fold.max(values_by_key, default)`

  numeric. if a default is supplied, returns the maximum from the supplied values *and* the default.
  if a default is *not* supplied, returns `nil` if there are no values, otherwise the maximum from amongst the values.

### provided "hud lines"

* `status_effects.hud_line.numeric`

  use this to display simple numeric values

* `status_effects.hud_line.make_numeric(default, format, time_format)`

  this will generate a custom numeric line formatter

* `status_effects.hud_line.enabled_or_blocked`

  use this to show whether an effect is enabled or blocked.
