local f = string.format

local StatusEffect = futil.class1()

function StatusEffect:_init(name, def)
	self._name = name
	futil.table.set_all(self, def)

	local monoid_def = {
		fold = def.fold,
	}

	self._registered_on_changes = { def.apply }
	function monoid_def.on_change(old_total, new_total, player)
		for _, callback in ipairs(self._registered_on_changes) do
			callback(self, player, new_total, old_total)
		end
	end

	self._monoid = persistent_monoids.make_monoid("status_effects:" .. name, monoid_def)
end

function StatusEffect:register_on_change(callback)
	table.insert(self._registered_on_changes, callback)
end

function StatusEffect:value(player)
	return self._monoid:value(player)
end

function StatusEffect:_remainings_key()
	return f("status_effect:%s:remainings", self._name)
end

function StatusEffect:_get_remainings(meta)
	local key = self:_remainings_key()
	return minetest.deserialize(meta:get(key)) or {}
end

function StatusEffect:_set_remainings(meta, remainings)
	local key = self:_remainings_key()
	if futil.table.is_empty(remainings) then
		return meta:set_string(key, "")
	else
		return meta:set_string(key, minetest.serialize(remainings))
	end
end

function StatusEffect:_set_remaining(player, key, value)
	local meta = player:get_meta()
	local remainings = self:_get_remainings(meta)
	remainings[key] = value
	self:_set_remainings(meta, remainings)
end

function StatusEffect:add(player, key, value)
	self:_set_remaining(player, key, nil)
	return self._monoid:add_change(player, value, key)
end

function StatusEffect:add_timed(player, key, value, time)
	self:_set_remaining(player, key, time)
	return self._monoid:add_change(player, value, key)
end

--[[
if no key, then clear all
]]
function StatusEffect:clear(player, key)
	if key then
		self:_set_remaining(player, key, nil)
		self._monoid:del_change(player, key)
	else
		self:_set_remainings(player:get_meta(), {})
		for key2 in pairs(self._monoid.player_map[player:get_player_name()]) do
			self._monoid:del_change(player, key2)
		end
	end
end

status_effects.StatusEffect = StatusEffect
