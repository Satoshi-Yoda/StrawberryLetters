require "camera"

Point = {}
Point.__index = Point

EMPTY = "empty"

local r = 0
local g = 0
local b = 255

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

function Point.readFromFile(file)
	local new = {}
	setmetatable(new, Point)

	new.x = file:read(8)
	new.y = file:read(8)
	new.deprecated_links = {}
	for i = 1,12 do
		if file:read(1) == "t" then
			new.deprecated_links[i] = true
		end
	end
	new.selected = false

	return new
end

function Point:writeToFile(file)
	file:write(self.x, 8)
	file:write(self.y, 8)
	for i = 1,12 do
		if self.deprecated_links[i] == true then
			file:write("t", 1)
		else
			file:write("f", 1)
		end
	end
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

function Point:rotateLinksLeft()
	local new_links = {}
	for i = 1,12 do
		local next_index = i + 1
		if next_index > 12 then next_index = 1 end
		new_links[i] = self.deprecated_links[next_index]
	end
	self.deprecated_links = new_links
end

function Point:rotateLinksRight()
	local new_links = {}
	for i = 1,12 do
		local next_index = i - 1
		if next_index < 1 then next_index = 12 end
		new_links[i] = self.deprecated_links[next_index]
	end
	self.deprecated_links = new_links
end

function Point:flipLinks()
	local new_links = {}
	for i = 1,12 do
		new_links[i] = self.deprecated_links[13 - i]
	end
	self.deprecated_links = new_links
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

	if love.keyboard.isDown("1") then
		r = 0
		g = 0
		b = 0
	elseif love.keyboard.isDown("2") then
		r = 16
		g = 16
		b = 16
	elseif love.keyboard.isDown("3") then
		r = 16*(3-1)
		g = 16*(3-1)
		b = 16*(3-1)
	elseif love.keyboard.isDown("4") then
		r = 16*(4-1)
		g = 16*(4-1)
		b = 16*(4-1)
	elseif love.keyboard.isDown("5") then
		r = 16*(5-1)
		g = 16*(5-1)
		b = 16*(5-1)
	elseif love.keyboard.isDown("6") then
		r = 16*(6-1)
		g = 16*(6-1)
		b = 16*(6-1)
	elseif love.keyboard.isDown("7") then
		r = 16*(7-1)
		g = 16*(7-1)
		b = 16*(7-1)
	elseif love.keyboard.isDown("8") then
		r = 16*(8-1)
		g = 16*(8-1)
		b = 16*(8-1)
	elseif love.keyboard.isDown("9") then
		r = 16*(9-1)
		g = 16*(9-1)
		b = 16*(9-1)
	elseif love.keyboard.isDown("0") then
		r = 0
		g = 0
		b = 255
	end

	if self.selected then
		love.graphics.setColor(255, 0, 0, 168 * camera.multipler())
	else
		love.graphics.setColor(r, g, b, 168 * camera.multipler())
	end

	love.graphics.circle("line", x, y, 1, 12)
	local radius = 5.3 * camera.scale

	local neighbours = self:getNeighbours()

	for i = 1,12 do
		local prev = i + 1
		if prev > 12 then prev = 1 end
		local angle = i * 2 * math.pi / 12
		local ex, ey
		if neighbours[i] == EMPTY and neighbours[prev] == EMPTY then
			local cr = 2
			local cx, cy = x + radius * math.sin(angle), y + radius * math.cos(angle)
			love.graphics.circle("line", cx, cy, cr, 6)
			ex, ey = x + (radius - cr) * math.sin(angle), y + (radius - cr) * math.cos(angle)
		else
			ex, ey = x + radius * math.sin(angle), y + radius * math.cos(angle)
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
					love.graphics.setColor(r, g, b, 168)
				end
				love.graphics.line(sx, sy, fx, fy)
			end
		end
	end
end
