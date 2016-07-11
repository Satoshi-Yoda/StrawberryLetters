require "camera"
require "Point"
require "Grid"

global = {
	grid = {},
	mode = "move"
}

function love.load()
	love.window.setMode(camera.w, camera.h, {resizable=false, vsync=true})
	love.graphics.setBackgroundColor(255, 255, 255)
	math.randomseed(os.time())
	love.window.setTitle("Strawberry Letters")

	global.grid = Grid.create()
end

function love.update(dt)
	camera.update(dt)
	global.grid:update(dt)
end

function love.draw()
	global.grid:draw()
end

