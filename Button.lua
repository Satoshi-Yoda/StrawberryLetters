Button = {}
Button.__index = Button

function Button.create(title, x, y, w, h, method)
	local new = {}
	setmetatable(new, Button)

	new.title = title
	new.x = x
	new.y = y
	new.w = w
	new.h = h
	new.method = method

	new.pressed = false
	new.mouseWasUp = false

	return new
end

function Button:update(dt)
	local mouse_x, mouse_y = love.mouse.getPosition()
	local x, y = self.x, self.y
	local inside = mouse_x >= x and mouse_y >= y and mouse_x <= x + self.w and mouse_y <= y + self.h
	local wasInside = false

	if love.mouse.isDown(1) then
		if inside then
			wasInside = true
			if self.mouseWasUp then
				self.pressed = true
			end
		else
			self.pressed = false
		end
		self.mouseWasUp = false
	else
		if inside then
			wasInside = true
			if self.mouseWasUp == false and self.pressed then
				self.method()
			end
		end
		self.pressed = false
		self.mouseWasUp = true
	end

	return wasInside
end

function Button:draw()
	local x, y = self.x, self.y

	if self.pressed then
		love.graphics.setColor(70, 50, 20)
	else
		love.graphics.setColor(110, 90, 60)
	end
	love.graphics.rectangle("fill", x, y, self.w, self.h)
	love.graphics.setLineWidth(1)
	love.graphics.setColor(170, 150, 120)
	love.graphics.rectangle("line", x, y, self.w, self.h)

	love.graphics.setColor(255, 255, 255)
	love.graphics.printf(self.title, x, y + self.h/2 - 7, self.w, "center")
end
