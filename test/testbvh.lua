local bvh = require("render.bvh.bvh")
local vector = require("structures.vector")
local mesh = require("render.meshgenerator")

---@return BVH
local function getgeometry()
  local box = mesh.box(vector.new(3, -1, -1, -1))
  local box2 = mesh.box(vector.new(3, 1, 1, 1))
  return bvh.new(table.unpack(box)):add(table.unpack(box2))
end

local function testboundingbox()
  local b = getgeometry():centerbounds()
  assert(b.max == vector.new(3, 2, 2, 2))
  assert(b.min == vector.new(3, -2, -2, -2))
end

local function testbuild()
  local box = mesh.box(vector.new(3, 0, 0, 0))
  ---@type BVH
  local b = bvh.new(table.unpack(box))
  b:build()
end

-- testboundingbox()
testbuild()

print("bvh test passed")
