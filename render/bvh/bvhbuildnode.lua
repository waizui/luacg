local lang = require("language")

---@class BVHBuildNode
---@field bounds Bounds
---@field left BVHBuildNode
---@field right BVHBuildNode
---@field spiltaxis number
---@field primoffset number  start index of primitives
---@field nprims number number of primitives
local BVHBuildNode = lang.newclass("BVHBuildNode")

function BVHBuildNode.leaf(offset, nprims, bounds)
	---@type BVHBuildNode
	local node = BVHBuildNode.new()
	node.primoffset = offset
	node.nprims = nprims
	node.bounds = bounds
	node.left = nil
	node.right = nil
	return node
end

---@param left BVHBuildNode
---@param right BVHBuildNode
function BVHBuildNode.interior(axis, left, right)
	---@type BVHBuildNode
	local node = BVHBuildNode.new()
	node.spiltaxis = axis
	node.left = left
	node.right = right
	node.bounds = left.bounds:union(right.bounds)
	return node
end

---@return boolean
function BVHBuildNode:isleaf()
  return not (self.left or self.right)
end

return BVHBuildNode
