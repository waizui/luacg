local data = require("structures.structure")

---@class MeshGenerator
local MeshGenerator = require("language").newclass("MeshGenerator")

function MeshGenerator.box(pos)
  --TODO: rotation
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

function MeshGenerator.sphere(pos, r, level)
  r = r or 1
  level = level or 8
  local vertice = {}

  table.insert(vertice, data.vec3(pos[1], r + pos[2], pos[3]))

  local slice, stack = level, level
  for i = 0, stack - 2 do
    local phi = (i + 1) / stack * math.pi
    for j = 0, slice - 1 do
      local theta = j / slice * math.pi * 2
      local x = r * math.sin(phi) * math.cos(theta) + pos[1]
      local y = r * math.cos(phi) + pos[2]
      local z = r * math.sin(phi) * math.sin(theta) + pos[3]
      table.insert(vertice, data.vec3(x, y, z))
    end
  end

  table.insert(vertice, data.vec3(pos[1], pos[2] - r, pos[3]))

  local s = {}
  for i = 1, slice do
    local vt = vertice[1]
    local v1, v2 = vertice[i + 1], vertice[i % slice + 2]
    table.insert(s, vt)
    table.insert(s, v1)
    table.insert(s, v2)

    local len = #vertice
    local vb = vertice[len]
    local v1b, v2b = vertice[len - i], vertice[len - (i % slice + 1)]
    table.insert(s, vb)
    table.insert(s, v1b)
    table.insert(s, v2b)
  end

  for j = 0, stack - 1 do
    local j1, j2 = j * slice + 2, (j + 1) * slice + 2

    for i = 1, slice do
      local i1, i2 = j1 + i, j1 + (i + 1) % slice
      local i3, i4 = j2 + (i + 1) % slice, j2 + i

      table.insert(s, vertice[i1])
      table.insert(s, vertice[i2])
      table.insert(s, vertice[i3])

      table.insert(s, vertice[i1])
      table.insert(s, vertice[i3])
      table.insert(s, vertice[i4])
    end
  end

  return s
end

return MeshGenerator
