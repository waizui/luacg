local Render = require("render.render")
local writebuf = require("util.pngencoder")
local data = require("structures.structure")
local bvh = require("render.bvh.bvh")
local mesh = require("render.meshgenerator")

---@param b BVH
local function addbox(b, pos)
  local box = mesh.box(pos)
  for i = 1, #box, 3 do
    b:add(data.primitive(1, 3, box[i], box[i + 1], box[i + 2]))
  end
end

local function addshpere(b, pos)
  local sphere = mesh.sphere(pos, 1, 32)
  for i = 1, #sphere, 3 do
    b:add(data.primitive(1, 3, sphere[i], sphere[i + 1], sphere[i + 2]))
  end
end

local function addshowcase(b, pos, size)
  local case = mesh.showcase(pos, size)
  for i = 1, #case, 3 do
    b:add(data.primitive(1, 3, case[i], case[i + 1], case[i + 2]))
  end
end

local function getbvh()
  ---@type BVH
  local b = bvh.new()

  addshowcase(b, data.vec3(0, 1.5, -7), 4)
  addbox(b, data.vec3(-1.5, -1.5, -7))
  addshpere(b, data.vec3(2, -1.5, -7))

  return b
end

local function ambient()
  local size = 128
  local b = getbvh()
  local buf = {}
  Render.ambientocclusion(size, size, b, buf, 10)
  writebuf(buf, size, size, "./ao.png")
end

return ambient
