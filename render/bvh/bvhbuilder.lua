local Lang = require("language")
local Vector = require("structures.vector")
local Bounds = require("render.bounds")
local BVHBuildNode = require("render.bvh.bvhbuildnode")
local BVHPrimitive = require("render.bvh.bvhprimitive")
local Primitive = require("render.primitive")
local ArrayUtil = require("util.arrayutil")

---@class BVHBuilder
---@field orderedprimitive  Primitive[]
---@field root  BVHBuildNode
local BVHBuilder = Lang.newclass("BVHBuilder")

---@param bvh BVH
function BVHBuilder:ctor(bvh)
  if not bvh then
    error("no bvh provided", -1)
  end

  self.bvh = bvh
end

---@return BVHBuildNode
function BVHBuilder:build()
  local bvhprims = {}
  for index, value in ipairs(self.bvh.primitives) do
    local prim = BVHPrimitive.new(index, value:bounds())
    table.insert(bvhprims, prim)
  end

  self.orderedprimitive = {}
  self.orderedprimoffset = 1 --offset from first element in orderedprimitive
  return self:buildrecursive(bvhprims)
end

---@param bvhprims BVHPrimitive[]
---@return BVHBuildNode
function BVHBuilder:buildrecursive(bvhprims)
  ---@type Bounds
  local bounds = Bounds.new()
  for _, b in ipairs(bvhprims) do
    bounds = bounds:union(b.bounds)
  end

  local nprim = #bvhprims

  if bounds:surfacearea() == 0 or nprim == 1 then
    return self:createleaf(bvhprims, bounds)
  else
    ---@type Bounds
    local centroidbounds = Bounds.new()
    for _, b in ipairs(bvhprims) do
      centroidbounds = centroidbounds:encapsulate(b.bounds:centroid())
    end

    local dim = centroidbounds:maxdimension()
    --is a point
    if centroidbounds.max[dim] == centroidbounds.min[dim] then
      return self:createleaf(bvhprims, bounds)
    else
      local mid = self:midpartition(bvhprims, centroidbounds, dim)
      local leftchild = self:buildrecursive(ArrayUtil.slice(bvhprims, 1, mid))
      local rightchild = self:buildrecursive(ArrayUtil.slice(bvhprims, mid + 1, nprim))
      return BVHBuildNode.interior(dim, leftchild, rightchild)
    end
  end
end

---@param bvhprims BVHPrimitive[]
---@param bounds Bounds centroidbounds
---@return number mid splitting index
function BVHBuilder:midpartition(bvhprims, bounds, dim)
  local nprim = #bvhprims
  local pmid = (bounds.min[dim] + bounds.max[dim]) / 2
  local mid = ArrayUtil.partition(bvhprims, 1, nprim, function(a, b)
    return a.bounds:centroid()[dim] > pmid
  end)

  if mid == 1 or mid == nprim then
    return nprim // 2
  end

  return mid
end

---@param bvhprims BVHPrimitive[]
---@param bounds Bounds leaf bounds
function BVHBuilder:createleaf(bvhprims, bounds)
  local nprim = #bvhprims
  local firstprimoffset = self.orderedprimoffset
  for i = 1, nprim do
    local primindex = bvhprims[i].primitiveindex
    self.orderedprimitive[firstprimoffset + i - 1] = self.bvh.primitives[primindex]
  end
  self.orderedprimoffset = firstprimoffset + nprim
  return BVHBuildNode.leaf(firstprimoffset, nprim, bounds)
end

return BVHBuilder
