local lang   = require("language")
local vector = require("structures.vector")

---@class BVH
local BVH    = lang.newclass("BVH")

---@class BVNode
local BVNode = lang.newclass("BVNode")

function BVNode:ctor()
end

---@class Bounds
local Bounds = lang.newclass("Bounds")

function Bounds:ctor()
  local v = math.huge
  self.max = vector.new(-v,-v,-v)
  self.min = vector.new(v,v,v)
end

function Bounds.union(a, b)
  local bounds = Bounds.new()

  bounds.max = vector.new(
    math.max(a.max[1], b.max[1]),
    math.max(a.max[2], b.max[2]),
    math.max(a.max[3], b.max[3])
  )

  bounds.min = vector.new(
    math.min(a.min[1], b.min[1]),
    math.min(a.min[2], b.min[2]),
    math.min(a.min[3], b.min[3])
  )
end

---@param p Primitives
function BVH:ctor(p)
  self.primitives = p
  self.nodecount = 0
end

function BVH:build()
  local p = self.primitives
end


function BVH.raycast(bvh, src, dir)
  --
end

---@param bvn BVH
function BVH.naiveraycast(bvn, src, dir)
  local p = bvn.primitives
  local depth = math.huge
  local hit = nil
  for i = 1, p.count do
    local obj = p:get(i)
    local v1, v2, v3 = obj[1], obj[2], obj[3]
    local res = BVH.mollertrumbore(src, dir, v1, v2, v3)
    if res then
      local d = (res - src):dot(dir)
      if d < depth then
        depth = d
        hit = res
      end
    end
  end

  return hit
end

-- moller trumbore raycast algorithm
-- ref: https://www.graphics.cornell.edu/pubs/1997/MT97.pdf
---@param dir Vector
---@param src Vector
---@param v1 Vector
---@param v2 Vector
---@param v3 Vector
function BVH.mollertrumbore(src, dir, v1, v2, v3)
  ---@type Vector
  local e1, e2 = v2 - v1, v3 - v1
  -- volume of parallelpiped e1, e2, dir
  -- ref: https://en.wikipedia.org/wiki/Triple_product
  local dirxe2 = dir:cross(e2)
  local vol = e1:dot(dirxe2)

  -- ray parallel  to triangle
  if math.abs(vol) < 1e-19 then
    return
  end

  -- determinant equals vol: dot(a,cross(b,c)) = det([a,b,c])
  local invdet, s = 1 / vol, src - v1
  -- cramer's rule xi = det(Ai)/det(A)
  local u = invdet * s:dot(dirxe2)
  if u < 0 or u > 1 then
    return
  end

  local sxe1 = s:cross(e1)
  local v = invdet * dir:dot(sxe1)
  -- careful check u + v > 1 they can be both less than 1
  if v < 0 or u + v > 1 then
    return
  end

  local t = invdet * e2:dot(sxe1)

  if t > 1e-19 then
    local hit = src + dir * t
    return hit
  end
end

return BVH, BVNode, Bounds
