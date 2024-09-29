local lang = require("language")
local vector = require("structures.vector")

---@class Bounds
---@field max Vector
---@field min Vector
local Bounds = lang.newclass("Bounds")

function Bounds:ctor()
  local v = math.huge
  self.max = vector.new(3, -v, -v, -v)
  self.min = vector.new(3, v, v, v)
end

---@param p Vector
---@return Bounds
function Bounds:encapsulate(p)
  local b = Bounds.new()
  b.min = vector.min(self.min, p)
  b.max = vector.max(self.max, p)
  return b
end

-- TODO: inplace update
---@param other Bounds
---@return Bounds
function Bounds:union(other)
  local b = Bounds.new()
  b.min = vector.min(self.min, other.min)
  b.max = vector.max(self.max, other.max)
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

---@return Vector
function Bounds:diagonal()
  return self.max - self.min
end

function Bounds:maxdimension()
  local d = self:diagonal()
  return d:maxcomponent()
end

function Bounds:centroid()
  return (self.min + self.max) * 0.5
end

function Bounds:surfacearea()
  local d = self:diagonal()
  return 2 * (d[1] * d[2] + d[2] * d[3] + d[1] * d[3])
end

---@param origin Vector
---@param dir Vector
---@return boolean,number|nil,number|nil -- if interscted, return tnear and tfar of a ray
function Bounds:intersect(origin, dir)
  local t1, t2 = 0, math.huge
  for i = 1, 3 do
    -- explaining see https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface#Bounds3::IntersectP
    -- basically, it is a algebraic deduction of a ray-bounding box intersection
    local invraydir = 1 / dir[i]
    local tnear = (self.min[i] - origin[i]) * invraydir
    local tfar = (self.max[i] - origin[i]) * invraydir
    if tnear > tfar then
      tnear, tfar = tfar, tnear
    end

    -- it may involve float point number's error rounding issue
    -- TODO: to avoid error rounding issue tFar *= 1 + 2 * gamma(3) is needed before the comparision

    -- update far and near for each component
    t1 = (tnear > t1 and tnear) or t1
    t2 = (tfar < t2 and tfar) or t2

    if t1 > t2 then
      -- near > far means there is no intersction
      return false
    end
  end

  return true, t1, t2
end

return Bounds
