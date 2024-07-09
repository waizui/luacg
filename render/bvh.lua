local Lang = require("language")
local Vector = require("structures.vector")
local Bounds = require("render.bounds")
local RefValue = require("structures.refvalue")
local BVHNode = require("render.bvhstructs")

---@class BVH
local BVH = Lang.newclass("BVH")

BVH.MAX_PRIMS_IN_NODE = 15

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
  local b = self:centerbounds()
  local mortons = self:buildmortonarray(b)
  local treelets = self:buildtreelets(mortons)
  self:buildhirachy(treelets, mortons)
  self:buildSAH(treelets, 1, #treelets)
end

---@param treelets [Treelet]
---@return BVHNode|nil
function BVH:buildSAH(treelets, start, over)
  local nNodes = over - start + 1
  if nNodes == 1 then
    return treelets[start].node
  end

  ---@type Bounds, Bounds
  local centroidbounds, bounds = Bounds.new(), Bounds.new()

  for i = start, over do
    local tr = treelets[i]
    bounds = bounds:union(tr.node.bounds)
    centroidbounds = centroidbounds:encapsulate(tr.node.bounds:centroid())
  end

  local nbuckets = 12
  ---@type [NodeBucket]
  local buckets = {}
  for i = 1, nbuckets do
    buckets[i] = { count = 0, bounds = Bounds.new() }
  end

  local dim = centroidbounds:maxdimension()

  for i = 1, nNodes do
    local tr = treelets[i]
    local cent = tr.node.bounds:centroid()
    local b = math.floor(nbuckets * centroidbounds:offset(cent)[dim]) + 1 --lua index from 1
    if b == nbuckets + 1 then
      b = b - 1
    end

    buckets[b].count = buckets[b].count + 1
    buckets[b].bounds = buckets[b].bounds:union(tr.node.bounds)
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
  local mid = BVH.partition(treelets, start, over, function(treelet)
    ---@type BVHNode
    local node = treelet.node
    local cent = node.bounds:centroid()

    local b = math.floor(nbuckets * centroidbounds:offset(cent)[dim]) + 1
    if b == nbuckets + 1 then
      b = b - 1
    end

    return b <= minsplit
  end)

  node:initinterior(dim, self:buildSAH(treelets, start, mid), self:buildSAH(treelets, mid + 1, over))
  return node
end

---@param predict function -- return if less than pivot
---@param list [Treelet]
---@return number --index of mid element
function BVH.partition(list, start, over, predict)
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

    BVH.swap(list, i, j)
  end

  return j
end

function BVH.swap(list, i, j)
  local tmp = list[i]
  list[i] = list[j]
  list[j] = tmp
end

--reorder primitives
---@param treelets  [Treelet]
---@param mortons [Morton]
function BVH:buildhirachy(treelets, mortons)
  local orderedprims, nodes = {}, {}
  local primoffset = RefValue.new(1)
  local bitindex = 29 - 12
  for _, v in ipairs(treelets) do
    local root = self:emitBVH(v, mortons, bitindex, primoffset, v.nprims, orderedprims)
    primoffset = primoffset + v.nprims
    v.node = root
  end

  self.primitives = orderedprims
  return nodes
end

---@param bitindex number
---@param treelet Treelet
---@param mortons [Morton]
---@param primoffset RefValue -- start index of primitives that now been processing
---@param orderedprims table
function BVH:emitBVH(treelet, mortons, bitindex, primoffset, nprims, orderedprims)
  if bitindex < 0 or nprims < BVH.MAX_PRIMS_IN_NODE then
    ---@type Bounds
    local nodebounds = Bounds.new()
    for offset = 0, nprims do
      local mortonindex = treelet.start + offset
      local pindex = mortons[mortonindex].pindex
      orderedprims[(primoffset + offset):get()] = self.primitives[pindex]
      nodebounds = nodebounds:union(self.primitives[pindex]:bounds())
    end

    ---@type BVHNode
    local node = BVHNode.new()
    node:initleaf(primoffset:get(), nprims, nodebounds)
    table.insert(treelet.node, node)
    return node
  end

  local mask = 1 << bitindex

  -- if all primitives are in same side of splitting plane
  if (mortons[treelet.start].code & mask) == (mortons[treelet.start + nprims].code & mask) then
    return self:emitBVH(treelet, mortons, bitindex - 1, primoffset, nprims, orderedprims)
  end

  local isplit = BVH.binaryfind(mortons, 1, mask)

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
function BVH.binaryfind(mortons, startindex, mask)
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

  return BVH.clamp(startindex, 1, size)
end

function BVH.clamp(x, a, b)
  return math.min(math.max(x, a), b)
end

---@param mortons [Morton]
---@return [Treelet]
function BVH:buildtreelets(mortons)
  -- check hight 12bits , make total 2^12 clusters, 2^4 in every dimension
  local mask = 0x3FFC0000 --0b00111111111111000000000000000000
  local s, e = 1, 2
  local primcount = #mortons
  local treelet = {}
  while e <= primcount do
    if (e == primcount) or ((mortons[s].code & mask) ~= (mortons[e].code & mask)) then
      local nprims = e - s -- max nodes count will be 2*nprims-1
      table.insert(treelet, { start = s, nprims = nprims, node = {} })
      s = e
    end
    e = e + 1
  end

  return treelet
end

---@param b Bounds
---@return [number,number][]  -- {{ code,pindex}}
function BVH:buildmortonarray(b)
  local mortonarr, scale = {}, 1 << 10 -- use 10 bits representing morton number

  for i = 1, #self.primitives do
    ---@type Primitive
    local prims = self.primitives[i]
    local p = prims:centroid()
    local poffset = b:offset(p)
    local offset = Vector.toint(scale * poffset)
    table.insert(mortonarr, { code = BVH.mortoncode(offset), pindex = i })
  end

  --TODO: radixsort
  table.sort(mortonarr, function(m1, m2)
    return m1.code < m2.code -- ascending
  end)

  return mortonarr
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

function BVH.shiftleft3(x)
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
function BVH.mortoncode(v)
  return BVH.shiftleft3(v[3]) << 2 | BVH.shiftleft3(v[2]) << 1 | BVH.shiftleft3(v[1])
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

return BVH, BVHNode
