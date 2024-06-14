local data = require("structures.structure")

---@class Camera
local Camera = require("language").newclass("Camera")

function Camera:ctor(p, v, near, far, fov, aspect)
  -- TODO: world to viewspace transform

  p = p or data.vec3(0, 0, 0)
  v = v or data.vec3(0, 0, -1)
  near = near or 0.25
  far = far or 4
  fov = fov or 0.6
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

  self.nearh = h -- near plane h
  self.nearw = w
  self.pos = p
  self.dir = v
  self.near = near
  self.far = far
  self.fov = fov
  self.aspect = aspect or 1
  -- stylua: ignore
  self.matrixVP = data.mat4x4(
    m00, 0, m02, 0,
    0, m11, m12, 0,
    0, 0, m22, m23,
    0, 0, m32, 0)
end

function Camera:ray(wbuf, hbuf, i, j)
  -- mapping pixels into [0,1]
  local ix = ((i - 1) + 0.5) / wbuf
  local iy = ((j - 1) + 0.5) / hbuf

  -- define up according to camera rotation
  local up = data.vec3(0, 1, 0)
  local right = self.dir:cross(up):normalize()
  local u, v = self.nearw / 2, self.nearh / 2
  local lcorner = (self.pos + self.dir * self.near) - (right * u + up * v)
  local ray = (lcorner + ix * 2 * u * right + iy * 2 * v * up) - self.pos
  return ray
end

return Camera
