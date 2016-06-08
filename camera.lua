camera = {}

camera.scale = 3

function camera.mm2px(x, y)
	return camera.scale * x, camera.scale * y
end

function camera.px2mm(x, y)
	return x / camera.scale, y / camera.scale
end
