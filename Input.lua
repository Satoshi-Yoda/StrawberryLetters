Input = {}
Input.__index = Input

CHARACTERS = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
			  '1','2','3','4','5','6','7','8','9','0','-'}

function Input.create(title, x, y, w, h, method)
	local new = {}
	setmetatable(new, Input)

	new.title = title
	new.text = ""
	new.x = x
	new.y = y
	new.w = w
	new.h = h
	new.method = method
	new.time = 0
	new.cursor = true
	new.done = false

	new.pressed = {}
	for _,c in pairs(CHARACTERS) do
		new.pressed[c] = false
	end

	return new
end

function Input:update(dt)
	local wasButton = false

	self.time = self.time + dt
	if math.floor(self.time) - self.time > -0.5 then
		self.cursor = true
	else
		self.cursor = false
	end

	for _,c in pairs(CHARACTERS) do
		if love.keyboard.isDown(c) then
			if self.pressed[c] == false then
				self.text = self.text .. c
				self.pressed[c] = true
				wasButton = true
			end
		else
			self.pressed[c] = false
		end

		if love.keyboard.isDown("backspace") then
			if self.pressed["backspace"] == false then
				self.text = string.sub(self.text, 1, #self.text - 1)
				self.pressed["backspace"] = true
				wasButton = true
			end
		else
			self.pressed["backspace"] = false
		end

		if love.keyboard.isDown("return") and self.done == false then
			self.method(self)
			self.done = true
			wasButton = true
		end
	end

	return wasButton
end

function Input:draw()
	local x, y = self.x, self.y

	love.graphics.setColor(110, 90, 60)
	love.graphics.rectangle("fill", x, y, self.w, self.h)
	love.graphics.setLineWidth(1)
	love.graphics.setColor(170, 150, 120)
	love.graphics.rectangle("line", x, y, self.w, self.h)

	love.graphics.setColor(255, 255, 255)
	local text = self.text
	if self.cursor then text = text .. "|" end
	love.graphics.printf(text, x + 5, y + self.h/2 - 7, 9999, "left")

	love.graphics.setColor(255, 255, 255)
	love.graphics.printf(self.title, x, y + self.h/2 - 32, 9999, "left")
	love.graphics.setColor(55, 45, 30)
	love.graphics.printf(self.title, x + 1, y + 1 + self.h/2 - 32, 9999, "left")
end
