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

function _rotate_selection(angle_sign)
	local cx, cy = global.grid:get_selection_center()
	if cx == nil then return end
	local cp = global.grid:get_nearest(cx, cy)

	for _,p in pairs(global.grid.points) do
	if p.selected then
		local ax = p.x - cp.x
		local ay = p.y - cp.y
		angle = math.pi/6 * angle_sign
		local p_x = cp.x + ax * math.cos(angle) - ay * math.sin(angle)
		local p_y = cp.y + ax * math.sin(angle) + ay * math.cos(angle)
		if angle_sign < 0
			then p:rotateLinksRight()
			else p:rotateLinksLeft()
		end
		global.grid:movePoint(p, p_x, p_y)
	end
	end

	-- TODO something wrong in hash, so I need this
	for _,p in pairs(global.grid.points) do
		global.grid:movePoint(p, p.x, p.y)
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

	-- TODO something wrong in hash, so I need this
	for _,p in pairs(global.grid.points) do
		global.grid:movePoint(p, p.x, p.y)
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

	local newButton = Button.create("rotate CW", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
		_rotate_selection(1)
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + BUTTON_HEIGHT

	local newButton = Button.create("rotate CCW", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
		_rotate_selection(-1)
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

	local newButton = Button.create("around \\", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
		_around_selection(false)
		global.menu.buttons = {}
	end)
	table.insert(self.buttons, newButton)
	y = y + BUTTON_HEIGHT

	local newButton = Button.create("around /", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
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

function Menu:createRemoveInput(x, y)
	self.buttons = {}

	local newInput = Input.create("Enter '<name>.group' for remove", x, y, 240, BUTTON_HEIGHT, function(input)
		local files = love.filesystem.getDirectoryItems("")
		for k,file in ipairs(files) do
			if file == input.text then
				love.filesystem.remove(file)
				print("Removed " .. file)
			end
		end
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

	local newButton = Button.create("remove saved group", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, function()
		global.menu:createRemoveInput(x, y)
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
