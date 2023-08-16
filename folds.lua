status_effects.fold = {}

function status_effects.fold.not_blocked(t)
	local enabled = false
	local blocked = false
	for _, value in pairs(t) do
		if value then
			enabled = true
		else
			blocked = true
		end
	end
	if blocked then
		return "blocked"
	else
		return enabled
	end
end

function status_effects.fold.nothing_false(t)
	return not futil.table.is_empty(t) and futil.functional.iall(futil.iterators.values(t))
end

function status_effects.fold.any(t)
	return futil.functional.iany(futil.iterators.values(t))
end

function status_effects.fold.sum(t, default)
	return futil.math.isum(futil.iterators.values(t), default or 0)
end

function status_effects.fold.max(t, default)
	local max = default
	for _, value in pairs(t) do
		if (not max) or value > max then
			max = value
		end
	end
	return max
end
