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

-- function Point:neighbours()
-- 	local result = {}
-- 	for i,x,y in utils.connection(utils.c12, self.x, self.y) do
-- 		if global.grid:has(x, y) then
-- 			table.insert(result, i)
-- 		end
-- 	end
-- 	return result
-- end

function Point:draw()
	local x, y = self.x * camera.scale, self.y * camera.scale

	love.graphics.setLineWidth(2)

	if self.selected then
		love.graphics.setColor(255, 0, 0, 128)
	else
		love.graphics.setColor(0, 0, 255, 128)
	end

	love.graphics.circle("line", x, y, 1, 12)
	local r = 5.3 * camera.scale

	-- love.graphics.line(x - r, y - r/2, x, y)
	-- love.graphics.line(x - r, y + r/2, x, y)
	-- love.graphics.line(x + r, y - r/2, x, y)
	-- love.graphics.line(x + r, y + r/2, x, y)
	-- love.graphics.line(x - r/2, y - r, x, y)
	-- love.graphics.line(x - r/2, y + r, x, y)
	-- love.graphics.line(x + r/2, y - r, x, y)
	-- love.graphics.line(x + r/2, y + r, x, y)
	-- love.graphics.line(x, y - r, x, y)
	-- love.graphics.line(x, y + r, x, y)
	-- love.graphics.line(x - r, y, x, y)
	-- love.graphics.line(x + r, y, x, y)

	for i = 0, 11 do
		local angle = i * 2 * math.pi / 12
		love.graphics.line(x + r * math.sin(angle), y + r * math.cos(angle), x, y)
	end

	love.graphics.setLineWidth(2)
	love.graphics.setColor(0, 0, 255, 255)
	for _,x,y in utils.connection(utils.c12, self.x, self.y) do
		if global.grid:has(x, y) then
			love.graphics.line(x * camera.scale, y * camera.scale, self.x * camera.scale, self.y * camera.scale)
		end
	end
end
