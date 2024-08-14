local lang = require("language")
local matrix = require("structures.matrix")
local vector = require("structures.vector")

--unit quaterion, do not modify components directly
---@class Quaternion
---@field r number
---@field i number
---@field j number
---@field k number
local Quaternion = lang.newclass("Quaternion")

function Quaternion:ctor(r, i, j, k)
  self.r = r -- cos(0)
  self.i = i
  self.j = j
  self.k = k
end

---@return Quaternion
function Quaternion.identity()
  return Quaternion.new(1, 0, 0, 0)
end

--rotate around x, y,z axes by degree x,y,z
---@param x number
---@param y number
---@param z number
---@return Quaternion
function Quaternion.euler(x, y, z) end

---@param degree number rotation in degree
---@param axis Vector rotation axis
---@return Quaternion
function Quaternion.angle(degree, axis)
  local rad = math.rad(degree)
  local c, s = math.cos(rad / 2), math.sin(rad / 2)
  local v = axis:normalize() * s
  return Quaternion.new(c, v[1], v[2], v[3])
end

---@param degree number
---@param axis Vector
function Quaternion:rotate(degree, axis)
  local q = Quaternion.angle(degree, axis)
  return self * q
end

--3x3 matrix representation of formular: pr = q*p*q^-1
---@return Matrix
function Quaternion:matrix()
  local r, i, j, k = self.r, self.i, self.j, self.k

  -- stylua: ignore
  -- unit quaterion, the element at [1,1] of origin 4x4 matrix is 1, not affecting calculation, thus omitted
  return matrix.new(3, 3, {
    1 - 2 * (j * j + k * k), 2 * (i * j - r * k), 2 * (i * k + r * j),
    2 * (i * j + r * k), 1 - 2 * (i * i + k * k), 2 * (j * k - r * i),
    2 * (i * k - r * j), 2 * (j * k + r * i), 1 - 2 * (i * i + j * j),
  })
end

---@return Quaternion
function Quaternion:conjugate()
  return Quaternion.new(self.r, -self.i, -self.j, -self.k)
end

---@param p Vector 3d
---@return Vector 3d
function Quaternion:rotatevec(p)
  local res = self:matrix():mul(p)
  return vector.new(3, res[1], res[2], res[3])
end

-- composing two quaterions by order a,b
---@param a Quaternion
---@param b Quaternion
---@return Quaternion
function Quaternion.__mul(a, b)
  local r = a.r * b.r - (a.i * b.i + a.j * b.j + a.k * b.k) -- a1a2−(b1b2+c1c2+d1d2)
  local i = a.r * b.i + b.r * a.i + a.j * b.k - a.k * b.j  -- a1b2+a2b1+c1d2−d1c2
  local j = a.r * b.j + b.r * a.j - a.i * b.k + a.k * b.i  -- a1c2+a2c1−b1d2+d1b2
  local k = a.r * b.k + b.r * a.k + a.i * b.j - a.j * b.i  -- a1d2+a2d1+b1c2−c1b2
  return Quaternion.new(r, i, j, k)
end

return Quaternion
