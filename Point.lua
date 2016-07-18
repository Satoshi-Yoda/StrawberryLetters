require "camera"

Point = {}
Point.__index = Point

EMPTY = "empty"

function Point.create(x, y)
	local new = {}
	setmetatable(new, Point)

	new.x = x
	new.y = y
	new.deprecated_links = {}
	new.selected = false

	return new
end

function Point.copy(point)
	local new = {}
	setmetatable(new, Point)

	new.x = point.x
	new.y = point.y
	new.deprecated_links = {}
	for i,l in pairs(point.deprecated_links) do
		new.deprecated_links[i] = l
	end
	new.selected = point.selected

	return new
end

function Point:getNeighbours()
	local neighbours = {}
	for i,x,y in utils.connection(utils.c12, self.x, self.y) do
		local point = global.grid:get(x, y)
		if point ~= nil then
			neighbours[i] = point
		else
			neighbours[i] = EMPTY
		end
	end
	return neighbours
end

function Point:possibleLinkTo(p)
	local neighbours = self:getNeighbours()
	for i,n in pairs(neighbours) do
		if n ~= EMPTY then
			if n == p then
				return true
			end
		end
	end
	return false
end

function Point:hasLinkTo(p)
	local neighbours = self:getNeighbours()
	for i,n in pairs(neighbours) do
		if n ~= EMPTY then
			if n == p and self.deprecated_links[i] ~= true then
				return true
			end
		end
	end
	return false
end

function Point:enableLinkTo(p)
	local neighbours = self:getNeighbours()
	for i,n in pairs(neighbours) do
		if n ~= EMPTY then
			if n == p then
				self.deprecated_links[i] = nil
			end
		end
	end
end

function Point:disableLinkTo(p)
	local neighbours = self:getNeighbours()
	for i,n in pairs(neighbours) do
		if n ~= EMPTY then
			if n == p then
				self.deprecated_links[i] = true
			end
		end
	end
end

function Point:draw()
	local x, y = camera.mm2px(self.x, self.y)

	love.graphics.setLineWidth(1)

	if self.selected then
		love.graphics.setColor(255, 0, 0, 168 * camera.multipler())
	else
		love.graphics.setColor(0, 0, 255, 168 * camera.multipler())
	end

	love.graphics.circle("line", x, y, 1, 12)
	local r = 5.3 * camera.scale

	local neighbours = self:getNeighbours()

	for i = 1,12 do
		local prev = i + 1
		if prev > 12 then prev = 1 end
		local angle = i * 2 * math.pi / 12
		local ex, ey
		if neighbours[i] == EMPTY and neighbours[prev] == EMPTY then
			local cr = 2
			local cx, cy = x + r * math.sin(angle), y + r * math.cos(angle)
			love.graphics.circle("line", cx, cy, cr, 6)
			ex, ey = x + (r - cr) * math.sin(angle), y + (r - cr) * math.cos(angle)
		else
			ex, ey = x + r * math.sin(angle), y + r * math.cos(angle)
		end
		love.graphics.line(ex, ey, x, y)
	end

	love.graphics.setLineWidth(4 * camera.multipler())
	for i = 1,12 do
		if neighbours[i] ~= EMPTY and self.deprecated_links[i] ~= true then
			local sx, sy = camera.mm2px(neighbours[i].x, neighbours[i].y)
			local fx, fy = camera.mm2px(self.x, self.y)
			local first_edge = (sx > fx) or ((sx == fx) and (sy > fy))
			if first_edge then
				if self.selected or neighbours[i].selected then
					love.graphics.setColor(255, 0, 0, 168)
				else
					love.graphics.setColor(0, 0, 255, 168)
				end
				love.graphics.line(sx, sy, fx, fy)
			end
		end
	end
end
