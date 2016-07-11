require "camera"

Point = {}
Point.__index = Point

function Point.create(x, y)
	local new = {}
	setmetatable(new, Point)

	new.x = x
	new.y = y
	new.selected = false

	return new
end

function Point:getNeighbours()
	local neighbours = {}
	for i,x,y in utils.connection(utils.c12, self.x, self.y) do
		local point = global.grid:get(x, y)
		if point ~= nil then
			neighbours[i] = point
		end
	end
	return neighbours
end

function Point:draw()
	local x, y = camera.mm2px(self.x, self.y)

	love.graphics.setLineWidth(1)

	if self.selected then
		love.graphics.setColor(255, 0, 0, 168)
	else
		love.graphics.setColor(0, 0, 255, 168)
	end

	love.graphics.circle("line", x, y, 1, 12)
	local r = 5.3 * camera.scale

	local neighbours = self:getNeighbours()

	for i = 1,12 do
		local prev = i + 1
		if prev > 12 then prev = 1 end
		local angle = i * 2 * math.pi / 12
		local ex, ey
		if neighbours[i] == nil and neighbours[prev] == nil then
			local cr = 2
			local cx, cy = x + r * math.sin(angle), y + r * math.cos(angle)
			love.graphics.circle("line", cx, cy, cr, 6)
			ex, ey = x + (r - cr) * math.sin(angle), y + (r - cr) * math.cos(angle)
		else
			ex, ey = x + r * math.sin(angle), y + r * math.cos(angle)
		end
		love.graphics.line(ex, ey, x, y)
	end

	love.graphics.setLineWidth(4)
	for i = 1,12 do
		if neighbours[i] ~= nil then
			local sx, sy = camera.mm2px(neighbours[i].x, neighbours[i].y) -- neighbours[i].x * camera.scale, neighbours[i].y * camera.scale
			local fx, fy = camera.mm2px(self.x, self.y) -- self.x * camera.scale, self.y * camera.scale
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
