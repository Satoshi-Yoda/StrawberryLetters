utils = {}
utils.math = {}

function utils.math.normalize(x, y, length)
	local l = math.sqrt(x * x + y * y)
	if l > 0 then
		local nx = x * length / l
		local ny = y * length / l
		return nx, ny
	else
		return 0, 0
	end
end

function utils.math.clamp(low, x, high)
	return math.min(math.max(low, x), high)
end

function utils.eight(x, y)
    return {{x-1, y}, {x+1, y}, {x, y-1}, {x, y+1}, {x-1, y+1}, {x+1, y-1}, {x-1, y-1}, {x+1, y+1}}
end

function utils.c12(x, y)
	local result = {}
	local r = 10.6
	for i = 0, 11 do
		local angle = math.pi / 12 + i * math.pi / 6
		local dx = r * math.sin(angle)
		local dy = r * math.cos(angle)
		table.insert(result, {x + dx, y + dy})
	end
	return result
end

function utils.c12s(x, y)
	local result = {}
	local r = 10.6
	for i = 0, 11 do
		local angle = i * math.pi / 6
		local dx = r * math.sin(angle)
		local dy = r * math.cos(angle)
		table.insert(result, {x + dx, y + dy})
	end
	return result
end

function utils.connection_iterator(table, i)
    i = i + 1
    local v = table[i]
    if v then
        return i, v[1], v[2]
    end
end

function utils.connection(type, x, y)
    return utils.connection_iterator, type(x, y), 0
end
