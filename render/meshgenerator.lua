local data = require("structures.structure")

---@class MeshGenerator
local MeshGenerator = require("language").newclass("MeshGenerator")

function MeshGenerator.box(pos)
  --TODO: translation
  local p1 = data.vec3(pos[1] - 1, pos[2] - 1, pos[3])
  local p2 = data.vec3(pos[1] + 1, pos[2] - 1, pos[3])
  local p3 = data.vec3(pos[1] + 1, pos[2] + 1, pos[3])
  local p4 = data.vec3(pos[1] - 1, pos[2] + 1, pos[3])

  local p5 = data.vec3(pos[1] - 1, pos[2] - 1, pos[3] - 4)
  local p6 = data.vec3(pos[1] + 1, pos[2] - 1, pos[3] - 4)
  local p7 = data.vec3(pos[1] + 1, pos[2] + 1, pos[3] - 4)
  local p8 = data.vec3(pos[1] - 1, pos[2] + 1, pos[3] - 4)

  -- stylua: ignore
  local box = {
    p1, p2, p3,
    p1, p3, p4,
    p5, p6, p7,
    p5, p7, p8,
    p4, p5, p7,
    p4, p7, p8,
    p2, p6, p7,
    p2, p7, p3,
    p1, p2, p6,
    p1, p6, p5,
    p5, p1, p8,
    p1, p4, p8,
  }
  return box
end

function MeshGenerator.sphere(pos, r)
  r = r or 1
  local vertice = {}

  table.insert(vertice, data.vec3(pos[1], r + pos[2], pos[3]))

  local slice, stack = 10, 10
  for i = 1, stack do
    local phi = i / stack * math.pi
    for j = 1, slice do
      local theta = j / slice * 2 * math.pi
      local x = r * math.sin(phi) * math.cos(theta) + pos[1]
      local y = math.cos(phi) + pos[2]
      local z = r * math.sin(phi) * math.sin(theta) + pos[3]
      table.insert(vertice, data.vec3(x, y, z))
    end
  end

  table.insert(vertice, data.vec3(pos[1], pos[2] - r, pos[3]))

  local s = {}
  for i = 1, slice do
    local vt, vb = vertice[1], vertice[#vertice]
    local v1, v2 = vertice[i + 1], vertice[(i + 1) % slice + 1]
    table.insert(s, vt)
    table.insert(s, v1)
    table.insert(s, v2)
    table.insert(s, vb)
    table.insert(s, v1)
    table.insert(s, v2)
  end

  return s
end

return MeshGenerator
