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

function Point:draw()
	local x, y = self.x * camera.scale, self.y * camera.scale

	if self.selected then
		love.graphics.setColor(255, 0, 0)
	else
		love.graphics.setColor(0, 0, 255)
	end

	love.graphics.circle("line", x, y, 1, 12)
	local r = 5 * camera.scale
	love.graphics.line(x - r, y - r/2, x, y)
	love.graphics.line(x - r, y + r/2, x, y)
	love.graphics.line(x + r, y - r/2, x, y)
	love.graphics.line(x + r, y + r/2, x, y)
	love.graphics.line(x - r/2, y - r, x, y)
	love.graphics.line(x - r/2, y + r, x, y)
	love.graphics.line(x + r/2, y - r, x, y)
	love.graphics.line(x + r/2, y + r, x, y)
	love.graphics.line(x, y - r, x, y)
	love.graphics.line(x, y + r, x, y)
	love.graphics.line(x - r, y, x, y)
	love.graphics.line(x + r, y, x, y)
end
