local Lang = require("language")
local Bounds = require("render.bounds")
local BVHBuilder = require("render.bvh.bvhbuilder")
local epsilon = require("util.mathutil").epsilon

---@class BVH
---@field root BVHBuildNode
---@field primitives Primitive[]
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
  ---@type BVHBuilder
  local builder = BVHBuilder.new(self)
  self.root = builder:build()
  self.primitives = builder.orderedprimitive
end

--- bounding box of all primitive's centroid
function BVH:centerbounds()
  ---@type Bounds
  local b = Bounds.new()

  for i = 1, #self.primitives do
    ---@type Primitive
    local prim = self.primitives[i]
    b = b:encapsulate(prim:centroid())
  end

  return b
end

---@param bvh BVH
---@param src Vector
---@param dir Vector
---@return Vector|nil
function BVH.raycast(bvh, src, dir)
  local t = BVH._raycastbvh(bvh, src, dir, bvh.root)
  if t then
    return src + dir * t
  end
end

---@param bvh BVH
---@param src Vector
---@param dir Vector
---@param node BVHBuildNode
---@return number|nil
function BVH._raycastbvh(bvh, src, dir, node)
  if not node then
    return
  end

  local ishit, tnear, tfar = node.bounds:intersect(src, dir)
  if not ishit then
    return
  end

  if node:isleaf() and node.nprims > 0 then
    local depth = math.huge
    local hitt = nil
    for i = 0, node.nprims - 1 do
      local index = i + node.primoffset
      local prim = bvh.primitives[index]
      local res, t = BVH.raycastprimitive(src, dir, prim)
      if res then
        local d = (res - src):dot(dir)
        if d < depth then
          depth = d
          hitt = t
        end
      end
    end

    return hitt
  end

  local lhit = BVH._raycastbvh(bvh, src, dir, node.left)
  local rhit = BVH._raycastbvh(bvh, src, dir, node.right)

  if lhit and rhit then
    -- use closet hit point
    return math.min(lhit, rhit)
  else
    return lhit or rhit
  end
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
      local res, t = BVH.mollertrumbore(src, dir, v1, v2, v3)
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

---@param src Vector
---@param dir Vector
---@param p Primitive
---@return Vector|nil,number|nil
function BVH.raycastprimitive(src, dir, p)
  local depth = math.huge
  local hit = nil
  local tt = nil
  for j = 1, p.count do
    local obj = p:get(j)
    local v1, v2, v3 = obj[1], obj[2], obj[3]
    local res, t = BVH.mollertrumbore(src, dir, v1, v2, v3)
    if res then
      local d = (res - src):dot(dir)
      if d < depth then
        depth = d
        hit = res
        tt = t
      end
    end
  end

  return hit, tt
end

-- moller trumbore raycast algorithm
-- ref: https://www.graphics.cornell.edu/pubs/1997/MT97.pdf
---@param dir Vector
---@param src Vector
---@param v1 Vector
---@param v2 Vector
---@param v3 Vector
---@return Vector|nil,number|nil
function BVH.mollertrumbore(src, dir, v1, v2, v3)
  ---@type Vector
  local e1, e2 = v2 - v1, v3 - v1
  -- volume of parallelpiped e1, e2, dir
  -- ref: https://en.wikipedia.org/wiki/Triple_product
  local dirxe2 = dir:cross(e2)
  local vol = e1:dot(dirxe2)

  -- ray parallel  to triangle
  if math.abs(vol) < epsilon then
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

  if t > epsilon then
    local hit = src + dir * t
    return hit, t
  end
end

---@param node BVHBuildNode
---@param b BVH
local function printnode(node, b)
  if node.left then
    printnode(node.left, b)
    printnode(node.right, b)
  end

  print("---")
  local min, max = node.bounds.min, node.bounds.max
  print("node", min:str(), ",", max:str())
  local cpos = node.bounds:centroid()
  if node.primoffset then
    local prim = b.primitives[node.primoffset]
    local ppos = prim:bounds():centroid()
    if cpos ~= ppos then
      print(ppos[1], ppos[2], ppos[3])
      error("centroid not equal", -1)
    end
  end
  print("---")
  print("\n")
end

function BVH:print()
  printnode(self.root, self)
end

return BVH
