require "Button"
require "Input"
require "Group"
require "camera"
require "utils"

Grid = {}
Grid.__index = Grid

function Grid.create(x, y)
	local new = {}
	setmetatable(new, Grid)

	new.points = {}
	new.savedGroups = {}
	new.buttons = {}
	new.time = 0
	new.add_interval = 0.0001
	new.add_count = 50

	new.mouseWasDown = false
	new.rightMouseWasDown = false
	new.upPressed = false
	new.downPressed = false
	new.leftPressed = false
	new.rightPressed = false

	return new
end

function Grid:createSaveButton(x, y)
	self.buttons = {}

	local mm_x, mm_y = camera.px2mm(x, y)

	local newButton = Button.create("save selection", x, y, 200, 30, function()
		global.grid:createInput(x, y)
	end)
	table.insert(self.buttons, newButton)
end

function Grid:createInput(x, y)
	self.buttons = {}

	local newInput = Input.create("Enter name and press Enter", x, y, 300, 30, function(input)
		local newGroup = Group.createFromSelection(input.text)
		table.insert(global.grid.savedGroups, newGroup)
	end)
	table.insert(self.buttons, newInput)
end

function Grid:createPlaceButtons(x, y)
	self.buttons = {}

	local mm_x, mm_y = camera.px2mm(x, y)

	local newButton = Button.create("point", x, y, 200, 30, function()
		global.grid:deselect()
		local x, y = global.grid:snapXY(mm_x, mm_y)
		global.grid:add(x, y, false)
		global.grid.buttons = {}
	end)
	table.insert(self.buttons, newButton)

	local newButton = Button.create("honeycomb 2 even", x, y + 30, 200, 30, function()
		global.grid:deselect()
		local x, y = global.grid:snapXY(mm_x, mm_y)
		global.grid:add(x, y, false)
		for i,cx,cy in utils.connection(utils.c12, x, y) do
			if i % 2 == 0 then
				global.grid:add(cx, cy, false)
			end
		end
		global.grid.buttons = {}
	end)
	table.insert(self.buttons, newButton)

	local newButton = Button.create("honeycomb 2 odd", x, y + 60, 200, 30, function()
		global.grid:deselect()
		local x, y = global.grid:snapXY(mm_x, mm_y)
		global.grid:add(x, y, false)
		for i,cx,cy in utils.connection(utils.c12, x, y) do
			if i % 2 == 1 then
				global.grid:add(cx, cy, false)
			end
		end
		global.grid.buttons = {}
	end)
	table.insert(self.buttons, newButton)

	local newButton = Button.create("honeycomb 3 even", x, y + 90, 200, 30, function()
		global.grid:deselect()
		local x, y = global.grid:snapXY(mm_x, mm_y)
		global.grid:add(x, y, false)
		for i,cx,cy in utils.connection(utils.c12, x, y) do
			if i % 2 == 1 then
				global.grid:add(cx, cy, false)
			end
		end
		for i,cx,cy in utils.connection(utils.c12, x, y) do
			local dx, dy = global.grid:lip(1.9*(cx - x) + x, 1.9*(cy - y) + y)
			global.grid:add(dx, dy, false)
		end
		global.grid.buttons = {}
	end)
	table.insert(self.buttons, newButton)

	local newButton = Button.create("honeycomb 3 odd", x, y + 120, 200, 30, function()
		global.grid:deselect()
		local x, y = global.grid:snapXY(mm_x, mm_y)
		global.grid:add(x, y, false)
		for i,cx,cy in utils.connection(utils.c12, x, y) do
			if i % 2 == 0 then
				global.grid:add(cx, cy, false)
			end
		end
		for i,cx,cy in utils.connection(utils.c12, x, y) do
			local dx, dy = global.grid:lip(1.9*(cx - x) + x, 1.9*(cy - y) + y)
			global.grid:add(dx, dy, false)
		end
		global.grid.buttons = {}
	end)
	table.insert(self.buttons, newButton)

	local newButton = Button.create("transformer 3 even", x, y + 150, 200, 30, function()
		global.grid:deselect()
		local x, y = global.grid:snapXY(mm_x, mm_y)
		global.grid:add(x, y, false)
		for i,cx,cy in utils.connection(utils.c12, x, y) do
			if i % 2 == 0 then
				global.grid:add(cx, cy, false)
			end
		end
		for i,cx,cy in utils.connection(utils.c12s, x, y) do
			local dx, dy = global.grid:lip(2*(cx - x) + x, 2*(cy - y) + y)
			global.grid:add(dx, dy, false)
		end
		global.grid.buttons = {}
	end)
	table.insert(self.buttons, newButton)

	local newButton = Button.create("transformer 3 odd", x, y + 180, 200, 30, function()
		global.grid:deselect()
		local x, y = global.grid:snapXY(mm_x, mm_y)
		global.grid:add(x, y, false)
		for i,cx,cy in utils.connection(utils.c12, x, y) do
			if i % 2 == 1 then
				global.grid:add(cx, cy, false)
			end
		end
		for i,cx,cy in utils.connection(utils.c12s, x, y) do
			local dx, dy = global.grid:lip(2*(cx - x) + x, 2*(cy - y) + y)
			global.grid:add(dx, dy, false)
		end
		global.grid.buttons = {}
	end)
	table.insert(self.buttons, newButton)

	for i,g in pairs(self.savedGroups) do
		local newButton = Button.create(g.name, x, y + 180 + i * 30, 200, 30, function()
			global.grid:deselect()
			local x, y = global.grid:snapXY(mm_x, mm_y)
			g:placeToGrid(x, y)
			global.grid.buttons = {}
		end)
		table.insert(self.buttons, newButton)
	end
end

function Grid:has(x, y, maxDistance)
	maxDistance = maxDistance or 0.5
	local x, y, distance = self:lip(x, y)
	return distance < maxDistance
end

function Grid:deselect()
	for _,p in pairs(self.points) do
		p.selected = false
	end
end

function Grid:add(x, y, removeSelection)
	if removeSelection == nil then removeSelection = true end

	-- x, y, distance = self:lip(x, y)
	-- if distance < 10.6 then return end

	if removeSelection then
		for _,p in pairs(self.points) do
			p.selected = false
		end
	end

	local newPoint = Point.create(x, y)
	newPoint.selected = true
	self:snap(newPoint)
	table.insert(self.points, newPoint)
end

function Grid:select(x, y)
	local nearest = nil
	local distance = math.huge
	local keepSelection = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") 
	
	for _,p in pairs(self.points) do
		local currentDistance = math.sqrt((x - p.x) * (x - p.x) + (y - p.y) * (y - p.y))
		if currentDistance < distance then
			distance = currentDistance
			nearest = p
		end
	end
	
	if nearest ~= nil and distance < 5.3 then
		if nearest.selected then
			self:expandSelection()
			keepSelection = true
		else
			nearest.willBeSelected = true
		end
	else
		self:add(x, y)
		self.buttons = {}
		keepSelection = true
	end

	for _,p in pairs(self.points) do
		if not keepSelection then
			p.selected = false
		end
		if p.willBeSelected then
			p.selected = true
			p.willBeSelected = nil
		end
	end
end

function Grid:expandSelection()
	for _,p in pairs(self.points) do
	if p.selected then
		local neighbours = p:getNeighbours()
		for _,n in pairs(neighbours) do
			n.willBeSelected = true
		end
	end
	end

	for _,p in pairs(self.points) do
	if p.willBeSelected then
		p.selected = true
		p.willBeSelected = nil
	end
	end
end

function Grid:lip(x, y)
	local nearest = nil
	local distance = math.huge
	for _,p in pairs(self.points) do
		local currentDistance = math.sqrt((x - p.x) * (x - p.x) + (y - p.y) * (y - p.y))
		if currentDistance < distance then
			distance = currentDistance
			nearest = p
		end
	end

	if nearest ~= nil then
		local vx, vy = nearest.x - x, nearest.y - y

		local nearest_x12 = nil
		local nearest_y12 = nil
		local distance12 = math.huge
		for _,x12,y12 in utils.connection(utils.c12, nearest.x, nearest.y) do
			local currentDistance12 = math.sqrt((x12 - x) * (x12 - x) + (y12 - y) * (y12 - y))
			if currentDistance12 < distance12 then
				distance12 = currentDistance12
				nearest_x12 = x12
				nearest_y12 = y12
			end
		end

		if nearest_x12 ~= nil then
			x, y = nearest_x12, nearest_y12
		end
	end

	return x, y, distance
end

function Grid:get(x, y)
	for _,p in pairs(self.points) do
		local distance = math.sqrt((p.x - x) * (p.x - x) + (p.y - y) * (p.y - y))
		if distance < 0.5 then
			return p
		end
	end
	return nil
end

function Grid:snap(point)
	point.x = 2.5 * math.floor(0.5 + (point.x / 2.5))
	point.y = 2.5 * math.floor(0.5 + (point.y / 2.5))
end

function Grid:snapXY(x, y)
	local new_x = 2.5 * math.floor(0.5 + (x / 2.5))
	local new_y = 2.5 * math.floor(0.5 + (y / 2.5))
	return new_x, new_y
end

function Grid:moveSelection()
	if love.keyboard.isDown("up") then
		if self.upPressed == false then
			for _,p in pairs(self.points) do
			if p.selected then
				p.y = p.y - 2.5
			end
			end
		end
		self.upPressed = true
	else
		self.upPressed = false
	end

	if love.keyboard.isDown("down") then
		if self.downPressed == false then
			for _,p in pairs(self.points) do
			if p.selected then
				p.y = p.y + 2.5
			end
			end
		end
		self.downPressed = true
	else
		self.downPressed = false
	end

	if love.keyboard.isDown("left") then
		if self.leftPressed == false then
			for _,p in pairs(self.points) do
			if p.selected then
				p.x = p.x - 2.5
			end
			end
		end
		self.leftPressed = true
	else
		self.leftPressed = false
	end

	if love.keyboard.isDown("right") then
		if self.rightPressed == false then
			for _,p in pairs(self.points) do
			if p.selected then
				p.x = p.x + 2.5
			end
			end
		end
		self.rightPressed = true
	else
		self.rightPressed = false
	end
end

function Grid:removeSelection()
	if love.keyboard.isDown("backspace") or love.keyboard.isDown("clear") or love.keyboard.isDown("delete") then
		for i,p in pairs(self.points) do
			if p.selected then
				table.remove(self.points, i)
			end
		end
	end
end

function Grid:selectionSize()
	local size = 0
	for _,p in pairs(self.points) do
		if p.selected then
			size = size + 1
		end
	end
	return size
end

function Grid:update(dt)
	local wasButton = false
	for _,b in pairs(self.buttons) do
		wasButton = wasButton or b:update(dt)
	end
	if wasButton then return end

	if love.mouse.isDown(1) then
		if self.mouseWasDown == false then
			local px_x, px_y = love.mouse.getPosition()
			local x, y = camera.px2mm(px_x, px_y)
			self:select(x, y)
		end
		self.mouseWasDown = true
	else
		self.mouseWasDown = false
	end

	if love.mouse.isDown(2) then
		if self.rightMouseWasDown == false then
			local px_x, px_y = love.mouse.getPosition()
			local mm_x, mm_y = camera.px2mm(px_x, px_y)
			if self:has(mm_x, mm_y, 6) then
				if self:selectionSize() > 0 then
					-- self:createPlaceButtons(px_x, px_y)
					-- self:createInput(px_x, px_y)
					self:createSaveButton(px_x, px_y)
				end
			else
				self:createPlaceButtons(px_x, px_y)
			end
		end
		self.rightMouseWasDown = true
	else
		self.rightMouseWasDown = false
	end

	-- if love.keyboard.isDown("tab") then
	-- 	if self.tabPressed == false then
	-- 		if global.mode == "add" then
	-- 			global.mode = "move"
	-- 		else
	-- 			global.mode = "add"
	-- 		end
	-- 		love.window.setTitle("mode = " .. global.mode)
	-- 	end
	-- 	self.tabPressed = true
	-- else
	-- 	self.tabPressed = false
	-- end

	if self:selectionSize() > 0 then
		self:moveSelection()
	else
		camera.move(dt)
	end

	self:removeSelection()

	-- self.time = self.time + dt
	-- if self.time > self.add_interval then
	-- 	self.time = 0
	-- 	for i = 1, self.add_count do
	-- 		local s = 10
	-- 		self:select(s + math.random((camera.w) / camera.scale - 2 * s), s + math.random((camera.h) / camera.scale - 2 * s))
	-- 	end
	-- end
end

function Grid:draw()
	love.graphics.setLineWidth(1)
	local s = math.floor((camera.w) / camera.scale)
	for x = -s, s, 1 do
		if x % 10 == 0 then
			love.graphics.setColor(255, 128, 0, 255)
		elseif x % 5 == 0 then
			love.graphics.setColor(255, 128, 0, 128)
		else
			love.graphics.setColor(255, 128, 0, 64)
		end
		local x1, y1 = camera.mm2px(x, -s)
		local x2, y2 = camera.mm2px(x, s)
		love.graphics.line(x1, y1, x2, y2)
	end
	for y = -s, s, 1 do
		if y % 10 == 0 then
			love.graphics.setColor(255, 128, 0, 255)
		elseif y % 5 == 0 then
			love.graphics.setColor(255, 128, 0, 128)
		else
			love.graphics.setColor(255, 128, 0, 64)
		end
		local x1, y1 = camera.mm2px(-s, y)
		local x2, y2 = camera.mm2px(s, y)
		love.graphics.line(x1, y1, x2, y2)
	end

	for _,p in pairs(self.points) do
		p:draw()
	end

	for _,b in pairs(self.buttons) do
		b:draw()
	end
end
