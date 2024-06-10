local data = require("structures")

local M = {}

function M.camera(p, v, near, far, fov, aspect)
  -- TODO: world to viewspace transform

  p = p or data.vec3(0, 0, 1)
  v = v or data.vec3(0, 0, -1)
  near = near or 0.25
  far = far or 4
  fov = fov or 0.8
  aspect = aspect or 1

  local h = near * fov
  local w = h / aspect
  local m00 = (2 * near) / w
  local m02 = 0 -- l+r = 0
  local m11 = (2 * near) / h
  local m12 = 0
  local m22 = (far + near) / (near - far)
  local m23 = (2 * far * near) / (near - far)
  local m32 = -1

  ---@class camera
  local camera = {
    pos = p,
    dir = v,
    near = near,
    far = far,
    fov = fov,
    aspect = aspect or 1,
    matrixVP = data.matrixr4x4(m00, 0, m02, 0, 0, m11, m12, 0, 0, 0, m22, m23, 0, 0, m32, 0),
  }

  return camera
end

function M.naiverasterize(w, h, tri, buf, cb)
  local matvp = M.camera().matrixVP
  local p1, p2, p3 = tri:vertex()
  local q1, q2, q3 = matvp:mul(p1), matvp:mul(p2), matvp:mul(p3)
  local w1, w2, w3 = q1[3], q2[3], q3[3]

  -- perspective division
  q1:scale(1 / w1)
  q1[4] = w1
  q2:scale(1 / w2)
  q2[4] = w2
  q3:scale(1 / w3)
  q3[4] = w3

  -- from top left corner to right bottom rasterize
  for i = h, 1, -1 do
    for j = 1, w do
      local ix = (2 * (j - 1) + 1) / w - 1
      local iy = (2 * (i - 1) + 1) / h - 1

      local s  = data.vec2(ix, iy)
      -- used for substraction s become -s
      s:scale(-1)


      local r1 = data.vec2(q1[1], q1[2])
      local r2 = data.vec2(q2[1], q2[2])
      local r3 = data.vec2(q3[1], q3[2])

      local area1 = data.cross2d(r2:add(s), r3:add(s))
      local area2 = data.cross2d(r3:add(s), r1:add(s))
      local area3 = data.cross2d(r1:add(s), r2:add(s))

      if area1 < 0 or area2 < 0 or area3 < 0 then
        goto continue
      end

      -- barycentric coordinates on screen space
      -- local area = area0 + area1 + area2
      -- local b = {}
      -- b[1] = area0 / area
      -- b[2] = area1 / area
      -- b[3] = area2 / area

      local res = cb(s, q1, q2, q3)
      buf[(h - i) * w + j] = res

      ::continue::
    end
  end
end

return M
