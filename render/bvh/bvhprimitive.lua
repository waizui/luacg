local Lang = require("language")

---@class BVHPrimitive
---@field primitiveindex number
---@field bounds Bounds
local BVHPrimitive = Lang.newclass("BVHPrimitive")

function BVHPrimitive:ctor(index, bounds)
	self.primitiveindex = index
	self.bounds = bounds
end

return BVHPrimitive
