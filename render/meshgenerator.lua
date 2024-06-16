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

function MeshGenerator.sphere(pos, r) end
for i = 1, r do
  for j = 1, r do
    --
  end
end

return MeshGenerator
