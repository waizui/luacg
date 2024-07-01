local lang = require("language")
local vector = require("structures.vector")

---@class Bounds
local Bounds = lang.newclass("Bounds")

function Bounds:ctor()
	local v = math.huge
	---@type Vector
	self.max = vector.new(3, -v, -v, -v)
	---@type Vector
	self.min = vector.new(3, v, v, v)
end

function Bounds.union(a, b)
	local bounds = Bounds.new()

  -- stylua: ignore
  bounds.max = vector.new(
    math.max(a.max[1], b.max[1]),
    math.max(a.max[2], b.max[2]),
    math.max(a.max[3], b.max[3]))

  -- stylua: ignore
  bounds.min = vector.new(
    math.min(a.min[1], b.min[1]),
    math.min(a.min[2], b.min[2]),
    math.min(a.min[3], b.min[3]))
end

---@param p Vector
function Bounds:encapsulate(p)
	local b = Bounds.new()
	b.min = vector.min(self.min, p)
	b.max = vector.max(self.max, p)
	return b
end

--return the offset of p from pmin to pmax in [0,1]
---@param b Bounds
---@param p Vector
---@return Vector
function Bounds.offset(b, p)
	local pMax, pMin = b.max, b.min
	local o = p - pMin

	if pMax[1] > pMin[1] then
		o[1] = o[1] / (pMax[1] - pMin[1])
	end

	if pMax[2] > pMin[2] then
		o[2] = o[2] / (pMax[2] - pMin[2])
	end

	if pMax[3] > pMin[3] then
		o[3] = o[3] / (pMax[3] - pMin[3])
	end

	return o
end

return Bounds
