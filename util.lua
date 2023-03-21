local f = string.format
local inf = tonumber("inf")

status_effects.util = {}

function status_effects.util.hud_time(remaining_time)
	if remaining_time == inf then
		return "inf"
	end

	local remaining_days = math.floor(remaining_time / (24 * 60 * 60))
	local remaining_hours = math.floor((remaining_time % (24 * 60 * 60)) / (60 * 60))
	local remaining_minutes = math.floor((remaining_time % (60 * 60)) / 60)
	local remaining_seconds = remaining_time % 60

	if remaining_days > 0 then
		return f("%02i:%02i:%02i:%04.1f", remaining_days, remaining_hours, remaining_minutes, remaining_seconds)
	elseif remaining_hours > 0 then
		return f("%02i:%02i:%04.1f", remaining_hours, remaining_minutes, remaining_seconds)
	elseif remaining_minutes > 0 then
		return f("%02i:%04.1f", remaining_minutes, remaining_seconds)
	else
		return f("%04.1f", remaining_seconds)
	end
end
