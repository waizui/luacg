local lang = require("language")
local vector = require("structures.vector")

---@class Bounds
local Bounds = lang.newclass("Bounds")

function Bounds:ctor()
	local v = math.huge
	self.max = vector.new(-v, -v, -v)
	self.min = vector.new(v, v, v)
end

function Bounds.union(a, b)
	local bounds = Bounds.new()

	bounds.max = vector.new(math.max(a.max[1], b.max[1]), math.max(a.max[2], b.max[2]), math.max(a.max[3], b.max[3]))

	bounds.min = vector.new(math.min(a.min[1], b.min[1]), math.min(a.min[2], b.min[2]), math.min(a.min[3], b.min[3]))
end

---@param p Vector
function Bounds:encapsulate(p)
  local b = Bounds.new()
  b.min =  vector.min(self.min,p)
  b.max = vector.max(self.max,p)
  return b
end

--return the offset of p from pmin to pmax in [0,1]
---@param b Bounds
---@param p Vector
---@return Vector
function Bounds.offset(b, p)
	local pMax, pMin = b.max, b.min
	local o = p - pMin

	if pMax.x > pMin.x then
		o.x = o.x / (pMax.x - pMin.x)
	end

	if pMax.y > pMin.y then
		o.y = o.y/(pMax.y - pMin.y)
	end

	if pMax.z > pMin.z then
		o.z = o.z/(pMax.z - pMin.z)
	end

	return o
end

return Bounds
