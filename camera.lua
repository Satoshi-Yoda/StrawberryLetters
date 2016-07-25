camera = {}

camera.scale = 4
camera.w = 800
camera.h = 800

camera.px_x = 0
camera.px_y = 0

camera.speed = 200

camera.zoomPressed = false
camera.unzoomPressed = false

function camera.multipler()
	return camera.scale / 4
end

function camera.update(dt)
	local changed = false

	if love.keyboard.isDown("=") then
		if camera.zoomPressed == false then
			camera.scale = camera.scale + 1
			changed = true
		end
		camera.zoomPressed = true
	else
		camera.zoomPressed = false
	end

	if love.keyboard.isDown("-") then
		if camera.unzoomPressed == false then
			camera.scale = camera.scale - 1
			changed = true
		end
		camera.unzoomPressed = true
	else
		camera.unzoomPressed = false
	end

	if changed then
		camera.scale = utils.math.clamp(1, camera.scale, 5)
	end

	if love.keyboard.isDown("c") or changed then
		camera.center()
	end
end

function camera.move(dt)
	if love.keyboard.isDown("left") then
		camera.px_x = camera.px_x + camera.speed * dt
	end
	if love.keyboard.isDown("right") then
		camera.px_x = camera.px_x - camera.speed * dt
	end
	if love.keyboard.isDown("up") then
		camera.px_y = camera.px_y + camera.speed * dt
	end
	if love.keyboard.isDown("down") then
		camera.px_y = camera.px_y - camera.speed * dt
	end
end

function camera.center()
	local cx, cy = global.grid:getCenter()
	camera.px_x, camera.px_y = -camera.scale * cx + camera.w / 2, -camera.scale * cy + camera.h / 2
end

function camera.mm2px(x, y)
	return camera.scale * x + camera.px_x, camera.scale * y + camera.px_y
end

function camera.px2mm(x, y)
	return (x - camera.px_x) / camera.scale, (y - camera.px_y) / camera.scale
end
