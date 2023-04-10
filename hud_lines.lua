local f = string.format
local S = status_effects.S
local inf = tonumber("inf")

status_effects.hud_line = {}

function status_effects.hud_line.boolean(self, player)
	local value = self:value(player)
	if type(value) ~= "boolean" then
		error(f("%s: invalid value of type %s for boolean hud line", self.name, type(value)))
	end
	if not value then
		return
	end
	local remaining = self:remaining_time(player)
	if remaining == inf then
		return S("@1", self.description)
	else
		return S("@1 (@3s)", self.description, f("%.1f", remaining))
	end
end

function status_effects.hud_line.numeric(self, player)
	local value = self:value(player)
	if type(value) ~= "number" then
		error(f("%s: invalid value of type %s for numeric hud line", self.name, type(value)))
	end
	if value == 0 then
		return
	end
	local remaining = self:remaining_time(player)
	if remaining == inf then
		return S("@1=@2", self.description, f("%.1f", value))
	else
		return S("@1=@2 (@3s)", self.description, f("%.1f", value), f("%.1f", remaining))
	end
end

function status_effects.hud_line.make_numeric(default, format, time_format)
	format = format or "%.1f"
	time_format = time_format or "%.1f"
	return function(self, player)
		local value = self:value(player)
		if type(value) ~= "number" then
			error(f("%s: invalid value of type %s for numeric hud line", self.name, type(value)))
		end
		if value == default then
			return
		end
		local remaining = self:remaining_time(player)
		if remaining == inf then
			return S("@1=@2", self.description, f(format, value))
		else
			return S("@1=@2 (@3s)", self.description, f(format, value), f(time_format, remaining))
		end
	end
end

function status_effects.hud_line.enabled_or_blocked(self, player)
	local value = self:value(player)
	if value == false or value == nil then
		return
	end

	local remaining = self:remaining_time(player)

	if value == "blocked" then
		if remaining == inf then
			return S("@1 blocked", self.description)
		else
			return S("@1 blocked (@2s)", self.description, f("%.1f", remaining))
		end
	elseif value then
		if remaining == inf then
			return self.description
		else
			return S("@1 (@2s)", self.description, f("%.1f", remaining))
		end
	end
end
