local Lang = require("language")
local Vector = require("structures.vector")
local Bounds = require("render.bounds")
local RefValue = require("structures.refvalue")
local BVHNode = require("render.bvh.bvhstructs")

---@class LBVHBuilder
---@field bvh BVH
local LBVHBuilder = Lang.newclass("LBVHBuilder")

function LBVHBuilder:ctor(bvh)
  if not bvh then
    error("no bvh provided", -1)
  end

  self.bvh = bvh
end

---@return BVHNode  -- root of bvh
function LBVHBuilder:build()
  local b = self.bvh:centerbounds()
  local mortons = self:buildmortonarray(b)
  local treelets = self:buildtreelets(mortons)
  self:buildhirachy(treelets, mortons)

  local nodestobuild = {}
  for i = 1, #treelets do
    local tr = treelets[i]
    table.insert(nodestobuild, tr.root)
  end

  return self:buildSAH(nodestobuild, 1, #treelets)
end

---@param nodestobuild [BVHNode]
---@return BVHNode
function LBVHBuilder:buildSAH(nodestobuild, start, over)
  local nNodes = over - start + 1
  if nNodes == 1 then
    return nodestobuild[start]
  end

  ---@type Bounds, Bounds
  local centroidbounds, bounds = Bounds.new(), Bounds.new()

  for i = start, over do
    local node = nodestobuild[i]
    bounds = bounds:union(node.bounds)
    local cent = node.bounds:centroid()
    centroidbounds = centroidbounds:encapsulate(cent)
  end

  local dim = centroidbounds:maxdimension()

  if centroidbounds.max == centroidbounds.min then
    -- all in same place, make it evenly split
    local node = BVHNode.new()
    local mid = (start + over) // 2
    node:initinterior(dim, self:buildSAH(nodestobuild, start, mid), self:buildSAH(nodestobuild, mid + 1, over))
    return node
  end

  local nbuckets = 12
  ---@type [NodeBucket]
  local buckets = {}
  for i = 1, nbuckets do
    buckets[i] = { count = 0, bounds = Bounds.new() }
  end

  for i = start, over do
    local node = nodestobuild[i]
    local cent = node.bounds:centroid()
    local b = math.floor(nbuckets * centroidbounds:offset(cent)[dim]) + 1 --lua index from 1
    if b == nbuckets + 1 then
      b = b - 1
    end

    buckets[b].count = buckets[b].count + 1
    buckets[b].bounds = buckets[b].bounds:union(node.bounds)
  end

  local costs = {}

  for i = 1, nbuckets do
    ---@type Bounds, Bounds
    local b0, b1 = Bounds.new(), Bounds.new()
    local count0, count1 = 0, 0
    for j = 1, i do
      b0 = b0:union(buckets[j].bounds)
      count0 = count0 + buckets[j].count
    end

    for j = i, nbuckets do
      b1 = b1:union(buckets[j].bounds)
      count1 = count1 + buckets[j].count
    end

    local s0, s1, s = b0:surfacearea(), b1:surfacearea(), bounds:surfacearea()
    costs[i] = 0.125 + (count0 * s0 + count1 * s1) / s
  end

  local mincost, minsplit = costs[1], 1

  for i = 1, nbuckets do
    if costs[i] < mincost then
      mincost = costs[i]
      minsplit = i
    end
  end

  ---@type BVHNode
  local node = BVHNode.new()
  local mid = LBVHBuilder.partition(nodestobuild, start, over, function(node)
    local cent = node.bounds:centroid()
    local b = math.floor(nbuckets * centroidbounds:offset(cent)[dim]) + 1
    if b == nbuckets + 1 then
      b = b - 1
    end

    return b <= minsplit
  end)

  if mid == over then
    mid = (start + over) // 2
  end

  local left = self:buildSAH(nodestobuild, start, mid)
  local right = self:buildSAH(nodestobuild, mid + 1, over)
  node:initinterior(dim, left, right)
  return node
end

---@param predict function -- return if less than pivot
---@param list [BVHNode]
---@return number --index of mid element
function LBVHBuilder.partition(list, start, over, predict)
  local i, j = start - 1, over + 1

  while true do
    while true do
      i = i + 1
      if not predict(list[i]) or i == over then
        break
      end
    end

    while true do
      j = j - 1
      if predict(list[j]) or j == start then
        break
      end
    end

    if i >= j then
      break
    end

    LBVHBuilder.swap(list, i, j)
  end

  return j
end

function LBVHBuilder.swap(list, i, j)
  local tmp = list[i]
  list[i] = list[j]
  list[j] = tmp
end

--reorder primitives by using the order of motorns
---@param treelets  [Treelet]
---@param mortons [Morton]
function LBVHBuilder:buildhirachy(treelets, mortons)
  local orderedprims, nodes = {}, {}
  local primoffset = RefValue.new(1)
  local bitindex = 29 - 12
  for _, v in ipairs(treelets) do
    local root = self:emitBVH(v, mortons, bitindex, primoffset, v.nprims, orderedprims)
    v.root = root
  end

  self.bvh.primitives = orderedprims
  return nodes
end

---@param bitindex number
---@param treelet Treelet
---@param mortons [Morton]
---@param primoffset RefValue -- start index of primitives that now been processing
---@param orderedprims table
function LBVHBuilder:emitBVH(treelet, mortons, bitindex, primoffset, nprims, orderedprims)
  if bitindex < 0 or nprims < self.bvh.MAX_PRIMS_IN_NODE then
    ---@type Bounds
    local nodebounds = Bounds.new()
    for offset = 0, nprims - 1 do
      local mortonindex = treelet.start + offset
      local pindex = mortons[mortonindex].pindex
      orderedprims[primoffset:get() + offset] = self.bvh.primitives[pindex]
      local pbounds = self.bvh.primitives[pindex]:bounds()
      nodebounds = nodebounds:union(pbounds)
    end

    ---@type BVHNode
    local node = BVHNode.new()
    node:initleaf(primoffset:get(), nprims, nodebounds)
    table.insert(treelet.nodes, node)
    primoffset = primoffset + nprims
    return node
  end

  local mask = 1 << bitindex

  -- if all primitives are in same side of splitting plane
  if (mortons[treelet.start].code & mask) == (mortons[treelet.start + nprims].code & mask) then
    return self:emitBVH(treelet, mortons, bitindex - 1, primoffset, nprims, orderedprims)
  end

  local isplit = LBVHBuilder.binaryfind(mortons, 1, mask)

  local left = self:emitBVH(treelet, mortons, bitindex - 1, primoffset, isplit - primoffset, orderedprims)
  local right = self:emitBVH(treelet, mortons, bitindex - 1, primoffset, nprims - (isplit - primoffset), orderedprims)
  local axis = bitindex % 3

  ---@type BVHNode
  local node = BVHNode.new()
  node:initinterior(axis, left, right)
  return node
end

-- find spilt index of nodes in a subtree
-- return the absolute index in motorns array
---@param mortons [Morton]
function LBVHBuilder.binaryfind(mortons, startindex, mask)
  local size = #mortons - startindex + 1
  while size > 0 do
    local half = math.floor(size / 2)
    local mid = startindex + half
    if (mortons[startindex].code & mask) == (mortons[mid].code & mask) then
      startindex = mid + 1
      size = size - half - 1
    else
      size = half
    end
  end

  return LBVHBuilder.clamp(startindex, 1, size)
end

function LBVHBuilder.clamp(x, a, b)
  return math.min(math.max(x, a), b)
end

--buid treelets for parallel building, finding primitives clusters in a treelet
---@param mortons [Morton]
---@return [Treelet]
function LBVHBuilder:buildtreelets(mortons)
  -- check hight 12bits , make total 2^12 clusters, 2^4 in every dimension
  local mask = 0x3FFC0000 --0b00111111111111000000000000000000
  local s, e = 1, 2      --start , end
  local primcount = #mortons
  local treelet = {}
  while e <= primcount + 1 do
    if (e == primcount + 1) or ((mortons[s].code & mask) ~= (mortons[e].code & mask)) then
      local nprims = e - s -- max nodes count will be 2*nprims-1
      table.insert(treelet, { start = s, nprims = nprims, nodes = {} })
      s = e
    end
    e = e + 1
  end

  return treelet
end

---@param b Bounds
---@return [number,number][]  -- {{ code,pindex}}
function LBVHBuilder:buildmortonarray(b)
  local mortonarr, scale = {}, 1 << 10 -- use 10 bits representing morton number

  for i = 1, #self.bvh.primitives do
    ---@type Primitive
    local prims = self.bvh.primitives[i]
    local p = prims:centroid()
    local poffset = b:offset(p)
    local offset = Vector.toint(scale * poffset)
    table.insert(mortonarr, { code = LBVHBuilder.mortoncode(offset), pindex = i })
  end

  --TODO: radixsort
  table.sort(mortonarr, function(m1, m2)
    return m1.code < m2.code -- ascending
  end)

  return mortonarr
end

function LBVHBuilder.shiftleft3(x)
  if x == 1 << 10 then
    x = x - 1
  end

  x = (x | (x << 16)) & 0x030000FF -- 0b00000011000000000000000011111111
  x = (x | (x << 8)) & 0x0300F00F -- 0b00000011000000001111000000001111
  x = (x | (x << 4)) & 0x030C30C3 -- 0b00000011000011000011000011000011
  x = (x | (x << 2)) & 0x09249249 -- 0b00001001001001001001001001001001
  return x & 0xFFFFFFFF
end

---@param v Vector
function LBVHBuilder.mortoncode(v)
  return LBVHBuilder.shiftleft3(v[3]) << 2 | LBVHBuilder.shiftleft3(v[2]) << 1 | LBVHBuilder.shiftleft3(v[1])
end

return LBVHBuilder
