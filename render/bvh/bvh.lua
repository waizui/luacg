local Lang = require("language")
local Bounds = require("render.bounds")
local LBHVBuilder = require("render.bvh.linearbvhbuilder")

---@class BVH
---@field root BVHNode
local BVH = Lang.newclass("BVH")

BVH.MAX_PRIMS_IN_NODE = 8

---@param ... Primitive
function BVH:ctor(...)
  ---@type Primitive[]
  self.primitives = {}
  self:add(...)
end

---@param ... Primitive
function BVH:add(...)
  for _, v in ipairs({ ... }) do
    table.insert(self.primitives, v)
  end
  return self
end

function BVH:build()
  ---@type LBVHBuilder
  local builder = LBHVBuilder.new(self)
  self.root = builder:build()
end

--- bounding box of all primitive's centroid
function BVH:centerbounds()
  ---@type Bounds
  local b = Bounds.new()

  for i = 1, #self.primitives do
    ---@type Primitive
    local prims = self.primitives[i]
    b = b:encapsulate(prims:centroid())
  end

  return b
end

function BVH.raycast(bvh, src, dir)
  --
end

---@param bvh BVH
function BVH.naiveraycast(bvh, src, dir)
  local depth = math.huge
  local hit = nil
  for i = 1, #bvh.primitives do
    local p = bvh.primitives[i]
    for j = 1, p.count do
      local obj = p:get(j)
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

return BVH
