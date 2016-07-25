require "camera"
require "Grid"
require "Menu"
require "Point"

global = {
	grid = {},
	menu = {},
}

function love.load()
	love.window.setMode(camera.w, camera.h, {resizable=false, vsync=true})
	love.graphics.setBackgroundColor(255, 255, 255)
	math.randomseed(os.time())
	love.window.setTitle("Strawberry Letters")

	global.grid = Grid.create()
	global.menu = Menu.create()
end

function love.update(dt)
	if global.menu:update(dt) then return end
	camera.update(dt)
	global.grid:update(dt)
	love.window.setTitle("Strawberry Letters"
		.. " points: " .. #global.grid.points)
end

function love.draw()
	global.grid:draw()
	global.menu:draw()
end
