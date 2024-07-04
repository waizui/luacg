local bvh = require("render.bvh")
local vector = require("structures.vector")
local data = require("structures.structure")
local render = require("render.render")
local mesh = require("render.meshgenerator")
local writebuf = require("util.pngencoder")

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

local function buildmortons()
  local b = getgeometry()
  local mortons = b:buildmortonarray(b:centerbounds())
  local treelets = b:buildtreelets(mortons)
  local nodes = b:buildhirachy(treelets, mortons)
end

testboundingbox()
buildmortons()

print("bvh test passed")
