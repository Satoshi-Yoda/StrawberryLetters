require "Button"
require "Input"
require "Group"
require "utils"

Menu = {}
Menu.__index = Menu

function Menu.create(x, y)
	local new = {}
	setmetatable(new, Menu)

	new.buttons = {}
	new.mouseWasDown = false

	return new
end

function Menu:createSaveButton(x, y)
	self.buttons = {}

	local mm_x, mm_y = camera.px2mm(x, y)

	local newButton = Button.create("save selection", x, y, 200, 30, function()
		global.menu:createInput(x, y)
	end)
	table.insert(self.buttons, newButton)
	y = y + 30

	local newButton = Button.create("rotate left", x, y, 200, 30, function()
		local cx, cy = global.grid:get_selection_center()
		if cx == nil then return end
		local cp = global.grid:get_nearest(cx, cy)

		for _,p in pairs(global.grid.points) do
		if p.selected then
			local ax = p.x - cp.x
			local ay = p.y - cp.y
			local alpha = math.pi/6
			p.x = cp.x + ax * math.cos(alpha) - ay * math.sin(alpha)
			p.y = cp.y + ax * math.sin(alpha) + ay * math.cos(alpha)
			p:rotateLinksLeft()
			global.grid:snap(p)
		end
		end
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + 30

	local newButton = Button.create("rotate right", x, y, 200, 30, function()
		local cx, cy = global.grid:get_selection_center()
		if cx == nil then return end
		local cp = global.grid:get_nearest(cx, cy)

		for _,p in pairs(global.grid.points) do
		if p.selected then
			local ax = p.x - cp.x
			local ay = p.y - cp.y
			local alpha = -math.pi/6
			p.x = cp.x + ax * math.cos(alpha) - ay * math.sin(alpha)
			p.y = cp.y + ax * math.sin(alpha) + ay * math.cos(alpha)
			p:rotateLinksRight()
			global.grid:snap(p)
		end
		end
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + 30

	local newButton = Button.create("round odd", x, y, 200, 30, function()
		print("round odd")
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + 30

	local newButton = Button.create("round even", x, y, 200, 30, function()
		print("round even")
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
end

function Menu:createInput(x, y)
	self.buttons = {}

	local newInput = Input.create("Enter name and press Enter", x, y, 300, 30, function(input)
		local newGroup = Group.createFromSelection(input.text)
		newGroup:saveToFile()
		table.insert(global.grid.savedGroups, newGroup)
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newInput)
end

function Menu:createPlaceButtons(x, y)
	self.buttons = {}

	local mm_x, mm_y = camera.px2mm(x, y)

	local newButton = Button.create("point", x, y, 200, 30, function()
		global.grid:deselect()
		local x, y = global.grid:snapXY(mm_x, mm_y)
		global.grid:add(x, y, false)
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + 30

	local newButton = Button.create("clean directory", x, y, 200, 30, function()
		local files = love.filesystem.getDirectoryItems("")
		for k,file in ipairs(files) do
			if string.find(file, "%.group") then
				love.filesystem.remove(file)
				print("Removed " .. file)
			end
		end
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + 30

	local newButton = Button.create("honeycomb 2 even", x, y, 200, 30, function()
		global.grid:deselect()
		local x, y = global.grid:snapXY(mm_x, mm_y)
		global.grid:add(x, y, false)
		for i,cx,cy in utils.connection(utils.c12, x, y) do
			if i % 2 == 0 then
				global.grid:add(cx, cy, false)
			end
		end
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + 30

	local newButton = Button.create("honeycomb 2 odd", x, y, 200, 30, function()
		global.grid:deselect()
		local x, y = global.grid:snapXY(mm_x, mm_y)
		global.grid:add(x, y, false)
		for i,cx,cy in utils.connection(utils.c12, x, y) do
			if i % 2 == 1 then
				global.grid:add(cx, cy, false)
			end
		end
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + 30

	local newButton = Button.create("honeycomb 3 even", x, y, 200, 30, function()
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
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + 30

	local newButton = Button.create("honeycomb 3 odd", x, y, 200, 30, function()
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
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + 30

	local newButton = Button.create("transformer 3 even", x, y, 200, 30, function()
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
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + 30

	local newButton = Button.create("transformer 3 odd", x, y, 200, 30, function()
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
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + 30

	global.grid:loadGroups()

	for i,g in pairs(global.grid.savedGroups) do
		local newButton = Button.create(g.name, x, y, 200, 30, function()
			global.grid:deselect()
			local x, y = global.grid:snapXY(mm_x, mm_y)
			g:placeToGrid(x, y)
			global.menu.buttons = {}
		end)
		table.insert(self.buttons, newButton)
		y = y + 30
	end
end

function Menu:update(dt)
	local wasButton = false
	for _,b in pairs(self.buttons) do
		wasButton = wasButton or b:update(dt)
	end

	local wasClick = false

	if love.mouse.isDown(1) or love.mouse.isDown(2) then
		if self.mouseWasDown == false then
			wasClick = true
		end
		self.mouseWasDown = true
	else
		self.mouseWasDown = false
	end

	if not wasButton and wasClick then
		self.buttons = {}
	end

	return #self.buttons > 0
end

function Menu:draw()
	for _,b in pairs(self.buttons) do
		b:draw()
	end
end
