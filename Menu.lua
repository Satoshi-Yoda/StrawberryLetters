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

	local newButton = Button.create("rotate left", x, y + 30, 200, 30, function()
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

	local newButton = Button.create("rotate right", x, y + 60, 200, 30, function()
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

	local newButton = Button.create("round odd", x, y + 90, 200, 30, function()
		local cx, cy = global.grid:get_selection_center()
		if cx == nil then return end
		local cp = global.grid:get_nearest(cx, cy)

		local max_distance = 0
		local highest_point = nil
		local highest_y = -math.huge
		for _,p in pairs(global.grid.points) do
		if p.selected then
			local current_distance = utils.math.distance(p.x, p.y, cp.x, cp.y)
			if current_distance > max_distance then
				max_distance = current_distance
			end
			if p.y > highest_y then
				highest_y = p.y
				highest_point = p
			end
		end
		end

		local additional_alpha = (highest_point.x == cp.x) or max_distance == 0

		max_distance = max_distance + 10
		local radial_count = math.floor(0.5 + max_distance / 10)
		local circle_count = 6 * radial_count

		for i = 0, circle_count - 1 do
			local alpha = 2 * math.pi * i / circle_count
			if additional_alpha then alpha = alpha + 2 * math.pi * 0.25 / circle_count end

			local new = {x = cp.x + max_distance * math.sin(alpha), y = cp.y + max_distance * math.cos(alpha)}
			global.grid:snap(new)
			while true do
				local vector = {x = cp.x - new.x, y = cp.y - new.y}
				vector.x, vector.y = utils.math.normalize(vector.x, vector.y, 2.5)
				local p_nearest, d_nearest = global.grid:get_nearest(new.x + vector.x, new.y + vector.y)
				if d_nearest > 9.2 then
					new.x = new.x + vector.x
					new.y = new.y + vector.y
					global.grid:snap(new)
				else
					break
				end
			end

			global.grid:add(new.x, new.y, false)
		end

		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)

	local newButton = Button.create("round even", x, y + 120, 200, 30, function()
		print("round even todo")
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
end

function Menu:createInput(x, y)
	self.buttons = {}

	local newInput = Input.create("Enter name and press Enter", x, y, 300, 30, function(input)
		local newGroup = Group.createFromSelection(input.text)
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

	local newButton = Button.create("honeycomb 2 even", x, y + 30, 200, 30, function()
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

	local newButton = Button.create("honeycomb 2 odd", x, y + 60, 200, 30, function()
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
		global.menu.buttons = {}
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
		global.menu.buttons = {}
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
		global.menu.buttons = {}
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
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)

	for i,g in pairs(global.grid.savedGroups) do
		local newButton = Button.create(g.name, x, y + 180 + i * 30, 200, 30, function()
			global.grid:deselect()
			local x, y = global.grid:snapXY(mm_x, mm_y)
			g:placeToGrid(x, y)
			global.menu.buttons = {}
		end)
		table.insert(self.buttons, newButton)
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
