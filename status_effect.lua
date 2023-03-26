local f = string.format

local StatusEffect = futil.class1()

function StatusEffect:_init(name, def)
	assert(def.fold)

	futil.table.set_all(self, def)

	self.name = name
	self.description = def.description or name
	self._registered_on_changes = { def.apply }

	local monoid_def = {
		fold = function(t)
			return def.fold(self, t)
		end,
		on_change = function(old_total, new_total, player)
			for _, callback in ipairs(self._registered_on_changes) do
				callback(self, player, new_total, old_total)
			end
		end,
	}

	self._monoid = persistent_monoids.make_monoid("status_effects:" .. name, monoid_def)
end

function StatusEffect:register_on_change(callback)
	table.insert(self._registered_on_changes, callback)
end

function StatusEffect:value(player, key)
	return self._monoid:value(player, key)
end

function StatusEffect:_remainings_key()
	return f("status_effect:%s:remainings", self.name)
end

function StatusEffect:_get_remainings(meta)
	local key = self:_remainings_key()
	return minetest.deserialize(meta:get_string(key)) or {}
end

function StatusEffect:_set_remainings(meta, remainings)
	local key = self:_remainings_key()
	if futil.table.is_empty(remainings) then
		return meta:set_string(key, "")
	else
		return meta:set_string(key, minetest.serialize(remainings))
	end
end

function StatusEffect:_set_remaining(player, key, remaining_time)
	local meta = player:get_meta()
	local remainings = self:_get_remainings(meta)
	remainings[key] = remaining_time
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

function StatusEffect:remaining_time(player, key)
	local meta = player:get_meta()
	local remainings = self:_get_remainings(meta)
	if key then
		return (remainings[key] or tonumber("inf")), self:value(player, key)
	else
		local current_value = self:value()
		local values = self._monoid:values()

		for id, remaining in futil.table.pairs_by_value(remainings) do
			values[id] = nil
			if self:fold(values) ~= current_value then
				return remaining, current_value
			end
		end

		return tonumber("inf"), current_value
	end
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
