local Render = require("render.render")
local writebuf = require("util.pngencoder")
local data = require("structures.structure")
local bvh = require("render.bvh.bvh")
local mesh = require("render.meshgenerator")
local vector = require("structures.vector")

local function getbvh()
  ---@type BVH
  local b = bvh.new()

  local box = mesh.box(vector.new(3, -1.5, -1.5, -7))
  for i = 1, #box, 3 do
    local offset = i * (1 / #box) * data.vec3(0, 0, 0)
    b:add(data.primitive(1, 3, offset + box[i], offset + box[i + 1], offset + box[i + 2]))
  end

  local sphere = mesh.sphere(vector.new(3, 1.5, 1.5, -6), 1)
  for i = 1, #sphere, 3 do
    b:add(data.primitive(1, 3, sphere[i], sphere[i + 1], sphere[i + 2]))
  end

  return b
end

local function testao()
  local size = 128
  local b = getbvh()
  local buf = {}
  Render.ambientocclusion(size, size, b, buf)
  writebuf(buf, size, size, "./ao.png")
end

testao()
