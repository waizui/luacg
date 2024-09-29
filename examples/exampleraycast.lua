local writebuf = require("util.pngencoder")
local data = require("structures.structure")
local render = require("render.render")
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

local function mapcolor(hit)
  local z = hit[3]
  local d = (z + 15) / 20 * 255
  return { d, d, d }
end

---@param navie boolean if true use naive raycast
local function raycast(w, h, navie)
  local buf = {}
  local b = getbvh()
  if navie then
    render.naiveraycastrasterize(w, h, b, buf, mapcolor)
  else
    render.raycastrasetrize(w, h, b, buf, mapcolor)
  end
  writebuf(buf, w, h, "./raycast.png")
end

return raycast
