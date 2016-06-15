camera = {}

camera.scale = 4
camera.w = 800
camera.h = 800

function camera.mm2px(x, y)
	return camera.scale * x, camera.scale * y
end

function camera.px2mm(x, y)
	return x / camera.scale, y / camera.scale
end
