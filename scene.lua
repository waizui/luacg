local data = require("structures")
local render = require("render")
local encode = require "pngencoder"

local rasterize = function(w, h)
  local p0 = data.vec4(-1, -1, -4, 1)
  local p1 = data.vec4(1, -1, -4, 1)
  local p2 = data.vec4(0, 1, -6, 1)

  local matvp = render.camera().matrixVP
  local q0, q1, q2 = matvp:mul(p0), matvp:mul(p1), matvp:mul(p2)
  local w0, w1, w2 = q0[3], q1[3], q2[3]

  -- perspective division
  q0:scale(1 / w0)
  q0[4] = w0
  q1:scale(1 / w1)
  q1[4] = w1
  q2:scale(1 / w2)
  q2[4] = w2

  local buf = {}

  -- from top left corner to right bottom rasterize
  for i = h, 1, -1 do
    for j = 1, w do
      local ix = (2 * (j - 1) + 1) / w - 1
      local iy = (2 * (i - 1) + 1) / h - 1

      local s = data.vec2(ix, iy)
      -- used for substraction s become -s
      s:scale(-1)

      local r0 = data.vec2(q0[1], q0[2])
      local r1 = data.vec2(q1[1], q1[2])
      local r2 = data.vec2(q2[1], q2[2])

      local area0 = data.cross2d(r1:add(s), r2:add(s))
      local area1 = data.cross2d(r2:add(s), r0:add(s))
      local area2 = data.cross2d(r0:add(s), r1:add(s))

      if area0 < 0 or area1 < 0 or area2 < 0 then
        goto continue
      end

      -- barycentric coordinates on screen space
      -- local area = area0 + area1 + area2
      -- local b = {}
      -- b[1] = area0 / area
      -- b[2] = area1 / area
      -- b[3] = area2 / area

      -- to get barycentric coordinates on projection space (perspective correct)
      -- ref: https://waizui.github.io/posts/barycentric/barycentric.html

      local coeff = data.matrixr4x4(
        q0[1] * w0, q1[1] * w1, q2[1] * w2, s[1],
        q0[2] * w0, q1[2] * w1, q2[2] * w2, s[2],
        q0[4], q1[4], q2[4], -1,
        1, 1, 1, 0
      )
      local rhs = data.vec4(0, 0, 0, 1)
      local b = data.inverse(coeff):mul(rhs)

      buf[(h - i) * w + j] = { b[1], b[2], b[3] }

      ::continue::
    end
  end

  -- write to png
  local png = encode(w, h)
  for i = 1, w * h do
    local v = buf[i]
    if not v then
      png:write { 0, 0, 0 }
    else
      png:write { (v[1] * 255), (v[2] * 255), (v[3] * 255) }
    end
  end

  assert(png.done)
  local pngbin = table.concat(png.output)
  local file = assert(io.open("./rasterize.png", "wb"))
  file:write(pngbin)
  file:close()
end

rasterize(64, 64)

print("terminated")
