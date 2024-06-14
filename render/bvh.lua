---@class BVH
local BVH = require("language").newclass("BVH")

---@class BVNode
local BVNode = require("language").newclass("BVNode")

function BVNode:ctor() end

---@param p Primitives
function BVH:ctor(p)
  self.primitives = p
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

return BVH, BVNode
