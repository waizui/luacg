local bvh = require("render.bvh")
local vector = require("structures.vector")
local data = require("structures.structure")
local render = require("render.render")
local mesh = require("render.meshgenerator")
local writebuf = require("util.pngencoder")

local function testboundingbox()
  local box = mesh.box(vector.new(3, -1, -1, -1))
  local box2 = mesh.box(vector.new(3, 1, 1, 1))
  local prim1 = data.primitive(1, 3, table.unpack(box))
  local prim2 = data.primitive(1, 3, table.unpack(box2))

  ---@type Bounds
  local b = bvh.new(prim1):add(prim2):boundingbox()
  assert(b.max == vector.new(3, 1, 1, 1))
  assert(b.min == vector.new(3, -1, -1, -1))
end

testboundingbox()
print("bvh test passed")
