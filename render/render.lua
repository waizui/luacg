local data = require("structures.structure")
local Camera = require("render.camera")
local StopWatch = require("util.stopwatch")
local Sampler = require("render.montecarlo.sampler")
local Matrix = require("structures.matrix")
local MathUtil = require("util.mathutil")

---@class Render
local Render = {}

---@return Camera
function Render.camera(p, v, near, far, fov, aspect)
  return Camera.new(p, v, near, far, fov, aspect)
end

---@param primitive Primitive
function Render.naiverasterize(w, h, primitive, buf, cb)
  local cam = Render.camera(data.vec3(0, 0, 0), data.vec3(0, 0, -1))
  local matvp = cam.matrixVP

  for ip = 1, primitive.count do
    local p = primitive:get(ip)

    local p1, p2, p3 = p[1], p[2], p[3]
    local uv1, uv2, uv3 = p[4], p[5], p[6]

    local q1, q2, q3 = matvp:mul(p1), matvp:mul(p2), matvp:mul(p3)
    local w1, w2, w3 = q1[4], q2[4], q3[4]

    -- perspective division
    q1 = q1 / w1
    q1[4] = w1
    q2 = q2 / w2
    q2[4] = w2
    q3 = q3 / w3
    q3[4] = w3

    -- from top left corner to right bottom rasterize
    for i = h, 1, -1 do
      for j = 1, w do
        local ix = (2 * (j - 1) + 1) / w - 1 -- centroid of pixel
        local iy = (2 * (i - 1) + 1) / h - 1
        -- screen coordinates
        local s = data.vec2(ix, iy)
        -- used for substraction s become -s
        s = s * -1

        local r1 = data.vec2(q1[1], q1[2])
        local r2 = data.vec2(q2[1], q2[2])
        local r3 = data.vec2(q3[1], q3[2])

        local area1 = (r2 + s):cross(r3 + s)
        local area2 = (r3 + s):cross(r1 + s)
        local area3 = (r1 + s):cross(r2 + s)

        if area1 < 0 or area2 < 0 or area3 < 0 then
          goto continue
        end

        -- barycentric coordinates on screen space
        -- local area = area0 + area1 + area2
        -- local b = {}
        -- b[1] = area0 / area
        -- b[2] = area1 / area
        -- b[3] = area2 / area

        local color = cb(s, { q1, q2, q3, uv1, uv2, uv3 })
        buf[(h - i) * w + j] = color

        ::continue::
      end
    end
  end
end

--- sample a moasic picture
---@return table
function Render.moasic(u, v)
  local n = 8
  local color = {}
  local d = math.floor(u * n) + math.floor(v * n)
  if d % 2 == 0 then
    color[1], color[2], color[3] = 0x40, 0x40, 0x40
  else
    color[1], color[2], color[3] = 0xFF, 0xFF, 0xFF
  end

  return color
end

---@param cb function per-pixel function
---@param bvh BVH
function Render.naiveraycastrasterize(w, h, bvh, buf, cb)
  -- fov 0.9
  local cam = Render.camera(nil, nil, nil, nil, 0.9, nil)

  ---@type StopWatch
  local sw = StopWatch.new()
  sw:start()

  -- from top left corner to right bottom rasterize
  for i = h, 1, -1 do
    for j = 1, w do
      local src, ray = cam.pos, cam:ray(w, h, j, i)
      local hit = nil
      hit = bvh:naiveraycast(src, ray)

      if not hit then
        goto continue
      end

      local color = cb(hit)
      buf[(h - i) * w + j] = color
      ::continue::
    end
  end
  sw:stop()
  print("naive ray casting finished in " .. sw:elapsed() .. "s")
end

---@param cb function per-pixel function
---@param bvh BVH
function Render.raycastrasetrize(w, h, bvh, buf, cb)
  -- fov 0.9
  local cam = Render.camera(nil, nil, nil, nil, 0.9, nil)
  local camdir = data.vec3(-0.1, -0.5, -1) --magic numbers
  cam:moveto(data.vec3(1, 3, 0.5) - camdir, camdir)
  bvh:build()

  ---@type StopWatch
  local sw = StopWatch.new()
  sw:start()

  -- from top left corner to right bottom rasterize
  for i = h, 1, -1 do
    for j = 1, w do
      local src, ray = cam.pos, cam:ray(w, h, j, i)
      local hit = nil
      hit = bvh:raycast(src, ray)

      if not hit then
        goto continue
      end

      local color = cb(hit)
      buf[(h - i) * w + j] = color
      ::continue::
    end
  end

  sw:stop()
  print("bvh accelerated ray casting finished in " .. sw:elapsed() .. "s")
end

---@param bvh BVH
function Render.ambientocclusion(w, h, bvh, buf, samplecount)
  -- fov 0.9
  local cam = Render.camera(nil, nil, nil, nil, 0.9, nil)
  local camdir = data.vec3(-0.1, -0.5, -1) --magic numbers
  cam:moveto(data.vec3(1, 3, 0.5) - camdir, camdir)

  -- local target = data.vec3(0, 0, 0)
  -- local campos = data.vec3(1, 0, 0)
  -- cam:moveto(campos, target - campos)
  bvh:build()

  -- from top left corner to right bottom rasterize
  for i = h, 1, -1 do
    for j = 1, w do
      local src, ray = cam.pos, cam:ray(w, h, j, i)
      local hit, hitindex = bvh:raycast(src, ray)

      if not hit then
        goto continue
      end

      local prim = bvh.primitives[hitindex]
      local normal = prim:normal()

      local color = Render.sampleambient(bvh, hit, normal, samplecount)
      buf[(h - i) * w + j] = { color, color, color }
      ::continue::
    end
  end
end

function Render.sampleambient(bvh, src, normal, count)
  count = count or 10
  local sum = 0
  for i = 1, count do
    local dir, pdf = Sampler.hemisphere()
    local worlddir = Render.o2w(normal):mul(dir)
    local vecdir = data.vec3(worlddir[1], worlddir[2], worlddir[3]):normalize()
    local hit, hitindex = bvh:raycast(src + normal * 0.001, vecdir)
    if not hit then
      sum = sum + dir[3] / pdf
    end
  end
  sum = sum / (count * math.pi)
  sum = MathUtil.clamp01(sum)
  return math.floor(sum * 255 + 0.5)
end

---@param normal Vector
---@return Matrix
function Render.o2w(normal)
  local right = data.vec3(1, 0, 0)
  local left = data.vec3(-1, 0, 0)
  if normal == right or normal == left then
    right = data.vec3(0, 1, 0)
  end
  local binormal = right:cross(normal)
  local tangent = binormal:cross(normal)
  ---@type Matrix
  local m = Matrix.new(3, 3, {
    tangent[1], binormal[1], normal[1],
    tangent[2], binormal[2], normal[2],
    tangent[3], binormal[3], normal[3],
  })
  return m
end

return Render
