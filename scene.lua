local data = require("structures")
local render = require("render")
local encode = require("pngencoder")

local writebuf = function(buf, w, h, fname)
  -- write to png
  local png = encode(w, h)
  for i = 1, w * h do
    local v = buf[i]
    if not v then
      png:write({ 0, 0, 0 })
    else
      png:write({ v[1], v[2], v[3] })
    end
  end

  assert(png.done)
  local pngbin = table.concat(png.output)
  local file = assert(io.open(fname, "wb"))
  file:write(pngbin)
  file:close()
end

local barycentric_coordinates = function(w, h)
  local p1 = data.vec4(-1, -1, -4, 1)
  local p2 = data.vec4(1, -1, -4, 1)
  local p3 = data.vec4(1, 1, -6, 1)
  local p4 = data.vec4(-1, 1, -6, 1)

  local tri1 = data.triangle(p1, p2, p3)
  local tri2 = data.triangle(p1, p3, p4)
  local buf = {}

  local cb = function(s, q1, q2, q3)
    -- to get barycentric coordinates on projection space (perspective correct)
    -- ref: https://waizui.github.io/posts/barycentric/barycentric.html
    local w1, w2, w3 = q1[4], q2[4], q3[4]
    -- stylua: ignore
    local coeff = data.matrixr4x4(
      q1[1] * w1, q2[1] * w2, q3[1] * w3, s[1],
      q1[2] * w1, q2[2] * w2, q3[2] * w3, s[2],
      q1[4], q2[4], q3[4], -1,
      1, 1, 1, 0
    )

    local rhs = data.vec4(0, 0, 0, 1)
    local inv = data.inverse(coeff)
    local im = inv:mul(coeff)
    local b = inv:mul(rhs)

    if math.abs(b[1]) > 1 or math.abs(b[2]) > 1 or math.abs(b[3]) > 1 then
      return { 0xFF, 0xFF, 0xFF }
    end

    return { b[1] * 255, b[2] * 255, b[3] * 255 }
  end

  render.naiverasterize(w, h, tri1, buf, cb)
  render.naiverasterize(w, h, tri2, buf, cb)

  writebuf(buf, w, h, "./rasterize.png")
end

barycentric_coordinates(64, 64)

print("terminated")
