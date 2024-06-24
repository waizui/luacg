local encode = require("util.pngencoder")

local test_png = function(w, h)
	local buf = {}

	for i = 1, w * h do
		buf[i] = { 255, 255, 255 }
	end
	-- write to png
	local png = encode(w, h)
	for i = 1, w * h do
		local v = buf[i]
		if not v then
			png:write({ 0, 0, 0 })
		else
			png:write({ v[1], v[2], v[3] })
		end
	end

	assert(png.done)
	local pngbin = table.concat(png.output)
	local file = assert(io.open("./testpng.png", "wb"))
	file:write(pngbin)
	file:close()
end

test_png(128, 128)

print("terminated")
