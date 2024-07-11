local Lang = require("language")

---@class Morton
---@field code number morton code
---@field pindex number primitive inex

---@class Treelet
---@field nodes BVHNode build nodes
---@field start number start index of motorns, start element is included
---@field nprims number motorns count , from start to start + nprims -1
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

function BVHNode:print()
  local nodes = {}
  BVHNode.traverse(self, 1, nodes)

  local str = {}
  for i = 1, #nodes do
    local nodesatlayer = nodes[i]
    table.insert(str, #nodesatlayer)
    for j = 1, #nodesatlayer do
      ---@type BVHNode
      local node = nodesatlayer[j]
      table.insert(str, string.format("[%s,%s]", node.primoffset, node.nprims))
    end
    table.insert(str, "\n")
  end

  print(table.concat(str))
end

---@param node BVHNode
---@param depth number
function BVHNode.traverse(node, depth, nodes)
  if node.left then
    BVHNode.traverse(node.left, depth + 1, nodes)
  end

  if node.right then
    BVHNode.traverse(node.right, depth + 1, nodes)
  end

  if not nodes[depth] then
    nodes[depth] = {}
  end

  table.insert(nodes[depth], node)
end

return BVHNode
