local Lang = require("language")

---@class Morton
---@field code number morton code
---@field pindex number primitive inex

---@class Treelet
---@field nodes BVHNode build nodes
---@field start number start index of primitives
---@field nprims number primitives count
---@field root BVHNode

---@class NodeBucket
---@field count number
---@field bounds Bounds

---@class BVHNode
---@field bounds Bounds
---@field nprims number
---@field primoffset number
local BVHNode = Lang.newclass("BVHNode")

function BVHNode:initleaf(offset, nprims, bounds)
  self.primoffset = offset
  self.nprims = nprims
  self.bounds = bounds
end

---@param left BVHNode
---@param right BVHNode
function BVHNode:initinterior(axis, left, right)
  self.axis = axis
  self.left = left
  self.right = right
  self.bounds = left.bounds:union(right.bounds)
end


return BVHNode
