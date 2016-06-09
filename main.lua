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
	love.window.setTitle("mode = " .. global.mode)

	global.grid = Grid.create()

	-- for i = 1, 10 do
	-- 	global.grid:add(math.random(w / camera.scale), math.random(h / camera.scale))
	-- end
end

function love.update(dt)
	global.grid:update(dt)
end

function love.draw()
	global.grid:draw()
end
