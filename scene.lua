local encode = require("util.pngencoder")
local data = require("structures.structure")
local render = require("render.render")
local bvh = require("render.bvh")
local mesh = require("render.meshgenerator")
local vector = require("structures.vector")

local writebuf = function(buf, w, h, fname)
  -- write to png
  local png = encode(w, h)
  for i = 1, w * h do
    local v = buf[i]
    if not v then
      png:write({ 0, 0, 0 })
    else
      png:write({math.floor( v[1]+0.5), math.floor(v[2]+0.5), math.floor(v[3]+0.5) })
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
  local p3 = data.vec4(1, 1, -8, 1)
  local p4 = data.vec4(-1, 1, -8, 1)
  local uv1, uv2 = data.vec2(0, 0), data.vec2(1, 0)
  local uv3, uv4 = data.vec2(1, 1), data.vec2(0, 1)

  local buf = {}

  local cb = function(s, p)
    -- to get barycentric coordinates on projection space (perspective correct)
    -- ref: https://waizui.github.io/posts/barycentric/barycentric.html
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

  local primitives = data.primitives(2, 3, p1, p2, p3, uv1, uv2, uv3)
  primitives:put(p1, p3, p4, uv1, uv3, uv4)

  render.naiverasterize(w, h, primitives, buf, cb)
  writebuf(buf, w, h, "./rasterize.png")
end

local raycast = function(w, h)
  local cb = function(hit)
    local z = hit[3]
    local d = (z + 15) / 20 * 255
    return { d, d, d }
  end

  local buf = {}
  local box = mesh.box(vector.new(3, -1.5, -1.5, -6))
  local sphere = mesh.sphere(vector.new(3, 1.5, 1.5, -6), 1)
  local primitives = data.primitives(1, 3, table.unpack(sphere))
  primitives:put(table.unpack(box))
  local b = bvh.new(primitives)
  render.raycastrasetrize(w, h, b, buf, cb)
  writebuf(buf, w, h, "./raycast.png")
end

local repl = function()
  local str = {
    "please select what to render",
    " [1]: rasterisation and  barycentric coordinates",
    " [2]: naive path tracing",
  }
  print(table.concat(str, "\n"))

  local i = io.read("*n")
  print("processing...")
  local size = 128
  if i == 1 then
    barycentric_coordinates(size, size)
  elseif i == 2 then
    raycast(size, size)
  else
    print("no such selection")
  end
end

repl()

print("finished")
