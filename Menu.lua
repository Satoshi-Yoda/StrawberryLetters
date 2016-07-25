require "Button"
require "Input"
require "Group"
require "utils"

Menu = {}
Menu.__index = Menu

BUTTON_HEIGHT = 24
BUTTON_WIDTH = 200

function Menu.create(x, y)
	local new = {}
	setmetatable(new, Menu)

	new.buttons = {}
	new.mouseWasDown = false

	return new
end

function _around_selection_old()
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
end

function _around_selection(shift)
	local highestPoint = nil
	local highest_y = math.huge
	for _,p in pairs(global.grid.points) do
	if p.selected then
		if p.y < highest_y then
			highest_y = p.y
			highestPoint = p
		end
	end
	end

	local vx = -2.5
	local vy = -10
	if shift then vx = 2.5 end
	local newPoint = global.grid:add(highestPoint.x + vx, highestPoint.y + vy, false)
	local firstPoint = newPoint

	while true do
		local temp_vx = vx
		local temp_vy = vy
		angle = -math.pi/6
		vx = temp_vx * math.cos(angle) - temp_vy * math.sin(angle)
		vy = temp_vx * math.sin(angle) + temp_vy * math.cos(angle)

		while true do
			local temp_vx = vx
			local temp_vy = vy
			angle = math.pi/6
			vx = temp_vx * math.cos(angle) - temp_vy * math.sin(angle)
			vy = temp_vx * math.sin(angle) + temp_vy * math.cos(angle)
			local point, distance = global.grid:get_nearest(newPoint.x + vx, newPoint.y + vy)
			if distance < 9 then
				if point == firstPoint then return end
				break
			end
		end
		local temp_vx = vx
		local temp_vy = vy
		angle = -math.pi/6
		vx = temp_vx * math.cos(angle) - temp_vy * math.sin(angle)
		vy = temp_vx * math.sin(angle) + temp_vy * math.cos(angle)
		newPoint = global.grid:add(newPoint.x + vx, newPoint.y + vy, false)
	end
end

function _rotate_selection(angle)
	local cx, cy = global.grid:get_selection_center()
	if cx == nil then return end
	local cp = global.grid:get_nearest(cx, cy)

	for _,p in pairs(global.grid.points) do
	if p.selected then
		local ax = p.x - cp.x
		local ay = p.y - cp.y
		local p_x = cp.x + ax * math.cos(angle) - ay * math.sin(angle)
		local p_y = cp.y + ax * math.sin(angle) + ay * math.cos(angle)
		p:rotateLinksRight()
		global.grid:movePoint(p, p_x, p_y)
	end
	end
end

function _flip_x_selection(angle)
	local cx, cy = global.grid:get_selection_center()
	if cx == nil then return end
	local cp = global.grid:get_nearest(cx, cy)

	for _,p in pairs(global.grid.points) do
	if p.selected then
		global.grid:movePoint(p, cp.x - (p.x - cp.x), p.y)
		p:flipLinks()
	end
	end
end

function Menu:createSaveButton(x, y)
	self.buttons = {}

	local mm_x, mm_y = camera.px2mm(x, y)

	local newButton = Button.create("save selection", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
		global.menu:createInput(x, y)
	end)
	table.insert(self.buttons, newButton)
	y = y + BUTTON_HEIGHT

	local newButton = Button.create("rotate left", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
		_rotate_selection(math.pi/6)
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + BUTTON_HEIGHT

	local newButton = Button.create("rotate right", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
		_rotate_selection(-math.pi/6)
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + BUTTON_HEIGHT

	local newButton = Button.create("flip", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
		_flip_x_selection()
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + BUTTON_HEIGHT

	local newButton = Button.create("around odd", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
		_around_selection(false)
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + BUTTON_HEIGHT

	local newButton = Button.create("around even", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
		_around_selection(true)
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
end

function Menu:createInput(x, y)
	self.buttons = {}

	local newInput = Input.create("Enter name and press Enter", x, y, 240, BUTTON_HEIGHT, function(input)
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

	local newButton = Button.create("point", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
		global.grid:deselect()
		local x, y = global.grid:snapXY(mm_x, mm_y)
		global.grid:add(x, y, false)
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + BUTTON_HEIGHT

	local newButton = Button.create("clean directory", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
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
	y = y + BUTTON_HEIGHT

	local newButton = Button.create("honeycomb 2", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
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
	y = y + BUTTON_HEIGHT

	local newButton = Button.create("honeycomb 3", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
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
	y = y + BUTTON_HEIGHT

	local newButton = Button.create("transformer 3", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
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
	y = y + BUTTON_HEIGHT

	global.grid:loadGroups()

	for i,g in pairs(global.grid.savedGroups) do
		local newButton = Button.create(g.name, x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
			global.grid:deselect()
			local x, y = global.grid:snapXY(mm_x, mm_y)
			g:placeToGrid(x, y)
			global.menu.buttons = {}
		end)
		table.insert(self.buttons, newButton)
		y = y + BUTTON_HEIGHT
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
