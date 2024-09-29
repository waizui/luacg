local bvh = require("render.bvh.bvh")
local vector = require("structures.vector")
local meshgen = require("render.meshgenerator")
local primitive = require("render.primitive")
local raycast = require("examples.exampleraycast")
local data = require("structures.structure")

---@param node BVHBuildNode
---@param b BVH
local function printnode(node, b)
  if node.left then
    printnode(node.left, b)
    printnode(node.right, b)
  end

  local cpos = node.bounds:centroid()
  print(cpos[1], cpos[2], cpos[3])
  if node.primoffset then
    local prim = b.primitives[node.primoffset]
    local ppos = prim:bounds():centroid()
    print(ppos[1], ppos[2], ppos[3])
    assert(cpos == ppos)
  end
  print("---")
end

---@return BVH
local function getgeometry()
  local box = meshgen.box(vector.new(3, -1, -1, -1))
  local box2 = meshgen.box(vector.new(3, 1, 1, 1))
  return bvh.new(table.unpack(box)):add(table.unpack(box2))
end

local function testboundingbox()
  local b = getgeometry():centerbounds()
  assert(b.max == vector.new(3, 2, 2, 2))
  assert(b.min == vector.new(3, -2, -2, -2))
end

local function testbuild()
  -- local box = mesh.box(vector.new(3, -1, -1, -1))
  -- local box2 = mesh.box(vector.new(3, 1, 1, 1))
  -- local b = bvh.new(table.unpack(box)):add(table.unpack(box2))
  -- local mesh = meshgen.box(vector.new(3, 0, 0, 0))
  local mesh = meshgen.uniformtriangle(4)

  local prims = {}

  for i = 0, #mesh / 3 - 1 do
    table.insert(prims, primitive.new(1, 3, mesh[i * 3 + 1], mesh[i * 3 + 2], mesh[i * 3 + 3]))
  end

  ---@type BVH
  local b = bvh.new(table.unpack(prims))
  b:build()
  local root = b.root
  printnode(root, b)
end

local function testcastbvh()
  local pos = data.vec3(-1, -1, -6)
  local p3 = data.vec3(pos[1] + 1, pos[2] + 1, pos[3] + 1)
  local p4 = data.vec3(pos[1] - 1, pos[2] + 1, pos[3] + 1)
  local p7 = data.vec3(pos[1] + 1, pos[2] + 1, pos[3] - 1)

  ---@type BVH
  local b = bvh.new(primitive.new(1, 3, p4, p3, p7))
  b:build()
  b:print()

  local src = data.vec3(0, 0, 0)
  local dir = 0.3 * p3 + 0.4 * p4 + 0.3 * p7
  b:raycast(src, dir)

  dir = data.vec3(-1,-1,0)
  b:raycast(src, dir)
end

-- testcastbvh()
-- testboundingbox()
-- testbuild()
raycast(128, 128, false)

print("bvh test passed")
