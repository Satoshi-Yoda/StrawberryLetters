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
	new.hash = {}
	new.savedGroups = {}
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

function Grid:loadGroups()
	self.savedGroups = {}
	local files = love.filesystem.getDirectoryItems("")
	for k,file in ipairs(files) do
		if string.find(file, "%.group") then
			local newGroup = Group.loadFromFile(file)
			table.insert(self.savedGroups, newGroup)
		end
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

function Grid:add(x, y, removeSelection, point)
	x, y = self:snapXY(x, y)

	if removeSelection == nil then removeSelection = true end

	-- x, y, distance = self:lip(x, y)
	-- if distance < 10.6 then return end

	if removeSelection then
		for _,p in pairs(self.points) do
			p.selected = false
		end
	end

	local newPoint
	if point ~= nil then
		newPoint = Point.copy(point)
		newPoint.x = x
		newPoint.y = y
	else
		newPoint = Point.create(x, y)
	end

	newPoint.selected = true
	table.insert(self.points, newPoint)
	self:hashPoint(newPoint)

	return newPoint
end

function Grid:hashPoint(point)
	self:snap(point)
	local hash_x = math.floor(0.5 + 2 * point.x)
	local hash_y = math.floor(0.5 + 2 * point.y)
	if self.hash[hash_x] == nil then
		self.hash[hash_x] = {}
	end
	self.hash[hash_x][hash_y] = point
end

function Grid:unhashPoint(point)
	local hash_x = math.floor(0.5 + 2 * point.x)
	local hash_y = math.floor(0.5 + 2 * point.y)
	if self.hash[hash_x] == nil then return end
	self.hash[hash_x][hash_y] = nil
end

function Grid:tryDisableLink(x, y)
	local result = false
	local p1 = nil
	local d1 = math.huge
	local p2 = nil
	local d2 = math.huge
	
	for _,p in pairs(self.points) do
		local d = utils.math.distance(p.x, p.y, x, y)
		if d < d1 then
			if d1 < d2 then
				p2 = p1
				d2 = d1
			end
			p1 = p
			d1 = d
		elseif d < d2 then
			p2 = p
			d2 = d
		end
	end

	if p1 ~= nil and p2 ~= nil then
		local cx = (p1.x + p2.x) / 2
		local cy = (p1.y + p2.y) / 2
		local d = utils.math.distance(cx, cy, x, y)
		if d < 5.3 / 3 then
			if p1:possibleLinkTo(p2) then
				if p1:hasLinkTo(p2) or p2:hasLinkTo(p1) then
					p1:disableLinkTo(p2)
					p2:disableLinkTo(p1)
					result = true
				else
					p1:enableLinkTo(p2)
					p2:enableLinkTo(p1)
					result = true
				end
			end
		end
	end
	return result
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
		-- self:add(x, y)
		self.buttons = {}
		-- keepSelection = true
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
			local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
			if n ~= EMPTY and (p:hasLinkTo(n) or n:hasLinkTo(p) or shift) then
				n.willBeSelected = true
			end
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

function Grid:checkLinks()
	for _,p in pairs(self.points) do
		for _,n in pairs(p:getNeighbours()) do
		if n ~= EMPTY then
			if p:hasLinkTo(n) and not n:hasLinkTo(p) then
				n:enableLinkTo(p)
			end
			if n:hasLinkTo(p) and not p:hasLinkTo(n) then
				p:enableLinkTo(n)
			end
		end
		end
	end
end

function Grid:movePoint(point, x, y)
	x, y = self:snapXY(x, y)
	self:unhashPoint(point)
	point.x = x
	point.y = y
	self:hashPoint(point)
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
	x, y = self:snapXY(x, y)
	local hash_x = math.floor(0.5 + 2 * x)
	local hash_y = math.floor(0.5 + 2 * y)
	if self.hash[hash_x] == nil then return nil end
	return self.hash[hash_x][hash_y]
end

function Grid:get_nearest(x, y)
	local d_min = math.huge
	local p_min = nil
	for _,p in pairs(self.points) do
		local distance = math.sqrt((p.x - x) * (p.x - x) + (p.y - y) * (p.y - y))
		if distance < d_min then
			d_min = distance
			p_min = p
		end
	end
	return p_min, d_min
end

function Grid:getCenter()
	local sum_x = 0
	local sum_y = 0
	local count = 0
	for _,p in pairs(self.points) do
		sum_x = sum_x + p.x
		sum_y = sum_y + p.y
		count = count + 1
	end

	if count == 0 then return 0, 0 end

	return sum_x / count, sum_y / count
end

function Grid:get_selection_center()
	local sum_x = 0
	local sum_y = 0
	local count = 0
	for _,p in pairs(self.points) do
	if p.selected then
		sum_x = sum_x + p.x
		sum_y = sum_y + p.y
		count = count + 1
	end
	end

	if count == 0 then return nil end

	return sum_x / count, sum_y / count
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
				self:movePoint(p, p.x, p.y - 2.5)
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
				self:movePoint(p, p.x, p.y + 2.5)
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
				self:movePoint(p, p.x - 2.5, p.y)
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
				self:movePoint(p, p.x + 2.5, p.y)
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
		local new_points = {}
		local removed = false
		for _,p in pairs(self.points) do
			if p.selected then
				self:unhashPoint(p)
				removed = true
			else
				table.insert(new_points, p)
			end
		end
		if removed then
			self.points = new_points
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
	self:checkLinks() -- TODO not every frame for all points, but for new one and for moved selection

	if love.mouse.isDown(1) then
		if self.mouseWasDown == false then
			local px_x, px_y = love.mouse.getPosition()
			local x, y = camera.px2mm(px_x, px_y)
			local result = self:tryDisableLink(x, y)
			if not result then self:select(x, y) end
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
					global.menu:createSaveButton(px_x, px_y)
				end
			else
				global.menu:createPlaceButtons(px_x, px_y)
			end
		end
		self.rightMouseWasDown = true
	else
		self.rightMouseWasDown = false
	end

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

	local s = 4
	local x_min, y_min = camera.px2mm(-s, -s)
	local x_max, y_max = camera.px2mm(camera.w + s, camera.h + s)
	x_min = math.floor(x_min)
	x_max = math.floor(x_max)
	y_min = math.floor(y_min)
	y_max = math.floor(y_max)

	for x = x_min, x_max, 1 do
		if x % 10 == 0 then
			love.graphics.setColor(255, 128, 0, 255 * camera.multipler())
		elseif x % 5 == 0 then
			love.graphics.setColor(255, 128, 0, 128 * camera.multipler())
		else
			love.graphics.setColor(255, 128, 0, 64 * camera.multipler())
		end
		local x1, y1 = camera.mm2px(x, y_min)
		local x2, y2 = camera.mm2px(x, y_max)
		love.graphics.line(x1, y1, x2, y2)
	end
	
	for y = y_min, y_max, 1 do
		if y % 10 == 0 then
			love.graphics.setColor(255, 128, 0, 255 * camera.multipler())
		elseif y % 5 == 0 then
			love.graphics.setColor(255, 128, 0, 128 * camera.multipler())
		else
			love.graphics.setColor(255, 128, 0, 64 * camera.multipler())
		end
		local x1, y1 = camera.mm2px(x_min, y)
		local x2, y2 = camera.mm2px(x_max, y)
		love.graphics.line(x1, y1, x2, y2)
	end

	for _,p in pairs(self.points) do
		p:draw()
	end
end
