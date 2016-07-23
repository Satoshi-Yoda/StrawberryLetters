require "camera"

Group = {}
Group.__index = Group

function Group.createFromSelection(name)
	local new = {}
	setmetatable(new, Group)

	new.name = name
	new.points = {}

	for _,p in pairs(global.grid.points) do
		if p.selected then
			table.insert(new.points, Point.copy(p))
		end
	end

	return new
end

function Group.loadFromFile(fileName)
	local new = {}
	setmetatable(new, Group)

	new.name = fileName
	new.points = {}

	print("loading group = " .. fileName)

	if not love.filesystem.exists(fileName) then
		print("Group.loadFromFile ERROR file not exists")
		return
	end
	local file = love.filesystem.newFile(fileName)
	file:open("r")
	local count = file:read(8)
	for i = 1, count do
		local newPoint = Point.readFromFile(file)
		table.insert(new.points, newPoint)
	end
	file:close()

	return new
end

function Group:getFileName()
	return self.name .. ".group"
end

function Group:saveToFile()
	if love.filesystem.exists(self:getFileName()) then love.filesystem.remove(self:getFileName()) end
	local file = love.filesystem.newFile(self:getFileName())
	file:open("w")
	file:write(#self.points, 8)
	for _,p in pairs(self.points) do
		p:writeToFile(file)
	end
	file:close()
end

function Group:placeToGrid(x, y)
	local cx, cy = 0, 0
	for _,p in pairs(self.points) do
		cx = cx + p.x
		cy = cy + p.y
	end
	cx, cy = cx / #self.points, cy / #self.points

	for _,p in pairs(self.points) do
		global.grid:add(p.x - cx + x, p.y - cy + y, false, p)
	end
end
