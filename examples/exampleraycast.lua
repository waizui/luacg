local writebuf = require("util.pngencoder")
local data = require("structures.structure")
local render = require("render.render")
local bvh = require("render.bvh.bvh")
local mesh = require("render.meshgenerator")
local vector = require("structures.vector")

local function raycast(w, h)
  local cb = function(hit)
    local z = hit[3]
    local d = (z + 15) / 20 * 255
    return { d, d, d }
  end

  local box = mesh.box(vector.new(3, -1.5, -1.5, -6))
  local sphere = mesh.sphere(vector.new(3, 1.5, 1.5, -6), 1)

  ---@type BVH
  local b = bvh.new(data.primitive(1, 3, table.unpack(sphere)))
  b:add(data.primitive(1, 3, table.unpack(box)))

  local buf = {}
  render.raycastrasetrize(w, h, b, buf, cb)
  writebuf(buf, w, h, "./raycast.png")
end

return raycast
