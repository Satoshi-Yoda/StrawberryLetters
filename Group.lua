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
