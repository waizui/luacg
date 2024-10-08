local writebuf = require("util.pngencoder")
local data = require("structures.structure")
local render = require("render.render")
local vector = require("structures.vector")
local quaternion = require("structures.quaternion")

local function homo(p)
  return vector.new(4, p[1], p[2], p[3] - 4, 1)
end

local rotation = function(w, h)
  -- local rotation = quaternion.angle(45, data.vec3(0, 0, 1)):rotate(-45, data.vec3(1, 0, 0))
  local rotation = quaternion.euler(nil, 45, 90)
  -- implementation of https://waizui.github.io/posts/a_glimpse_of_quaternion/a_glimpse_of_quaternion.html
  local p1 = homo(rotation:rotatevec(vector.new(3, -1, -1, 0)))
  local p2 = homo(rotation:rotatevec(vector.new(3, 1, -1, 0)))
  local p3 = homo(rotation:rotatevec(vector.new(3, 1, 1, 0)))
  local p4 = homo(rotation:rotatevec(vector.new(3, -1, 1, 0)))

  local uv1, uv2 = data.vec2(0, 0), data.vec2(1, 0)
  local uv3, uv4 = data.vec2(1, 1), data.vec2(0, 1)

  local buf = {}

  local cb = function(s, p)
    local q1, q2, q3 = p[1], p[2], p[3]
    local uv1, uv2, uv3 = p[4], p[5], p[6]

    local w1, w2, w3 = q1[4], q2[4], q3[4]
    -- stylua: ignore
    local coeff = data.mat4x4(
      q1[1] * w1, q2[1] * w2, q3[1] * w3, s[1],
      q1[2] * w1, q2[2] * w2, q3[2] * w3, s[2],
      q1[4], q2[4], q3[4], -1,
      1, 1, 1, 0
    )

    local rhs = data.vec4(0, 0, 0, 1)
    local inv = coeff:inverse()
    local b = inv:mul(rhs)

    local uv = uv1 * b[1] + uv2 * b[2] + uv3 * b[3]

    return render.moasic(uv[1], uv[2])
  end

  local primitive = data.primitive(2, 3, p1, p2, p3, uv1, uv2, uv3)
  primitive:put(p1, p3, p4, uv1, uv3, uv4)

  render.naiverasterize(w, h, primitive, buf, cb)
  writebuf(buf, w, h, "./rotation.png")
end

return rotation
