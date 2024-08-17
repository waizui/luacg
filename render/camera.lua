local data = require("structures.structure")

---@class Camera
---@field matrixP Matrix projection transform
---@field matrixV Matrix view transform
---@field matrixVP Matrix world to projection transform
---@field dir Vector view direction, shoot out from camera
---@field up Vector up direction
---@field pos Vector position of camera
---@field fov number field of view = h/near
---@field near number near plane distance
---@field far number far plane distance
---@field aspect number equals h/w
---@field nearh number height of near plane
---@field nearw number width of near plane
local Camera = require("language").newclass("Camera")

function Camera:ctor(p, v, near, far, fov, aspect)
  p = p or data.vec3(0, 0, 0)
  v = v or data.vec3(0, 0, -1)
  near = near or 0.25
  far = far or 4
  fov = fov or 0.6
  aspect = aspect or 1

  self:update(p, v, near, far, fov, aspect)
end

function Camera:update(p, v, near, far, fov, aspect)
  -- a good explanation:  https://learnwebgl.brown37.net/08_projections/projections_perspective.html
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
  self.aspect = aspect

  -- stylua: ignore
  self.matrixP = data.mat4x4(
    m00, 0, m02, 0,
    0, m11, m12, 0,
    0, 0, m22, m23,
    0, 0, m32, 0)

  self:lookat(v)
end

---@param v Vector view direction
function Camera:lookat(v)
  --use right handed coordinate system of camera space
  local forward = (-1 * v):normalize()
  local up = data.vec3(0, 1, 0)
  local right = up:cross(forward)
  up = forward:cross(right)
  self.dir = v
  self.up = up

  local pos = self.pos
  --[[
  let Vw be vector in world space, Vv be in view space, T be view transformation
  denoted by TVw = Vv,  because Vw = T^-1Vv, so T is the inverse of view to world transformation
  orthogonal matrix's inverse is transpose
  ]]
  -- stylua: ignore
  local vmat = data.mat4x4(
    right[1], up[1], forward[1], 0,
    right[2], up[2], forward[2], 0,
    right[3], up[3], forward[3], 0,
    0, 0, 0, 1
  ):transpose()

  -- translation
  vmat:set(1, 4, -pos[1])
  vmat:set(2, 4, -pos[2])
  vmat:set(3, 4, -pos[3])

  self.matrixV = vmat
  self.matrixVP = self.matrixP:mul(vmat)
end

--move camera to a position
---@param pos Vector
---@param v Vector|nil view direction
function Camera:moveto(pos, v)
  self.pos = pos
  self:lookat(v or self.dir)
end

function Camera:ray(wbuf, hbuf, i, j)
  -- mapping pixels into [0,1]
  local ix = ((i - 1) + 0.5) / wbuf
  local iy = ((j - 1) + 0.5) / hbuf

  local up = self.up
  local right = self.dir:cross(up):normalize()
  local u, v = self.nearw / 2, self.nearh / 2
  local lcorner = (self.pos + self.dir * self.near) - (right * u + up * v)
  local ray = (lcorner + ix * 2 * u * right + iy * 2 * v * up) - self.pos
  return ray
end

return Camera
