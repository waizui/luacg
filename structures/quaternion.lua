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

--3x3
---@return Matrix
function Quaternion:matrix()
  local r, i, j, k = self.r, self.i, self.j, self.k

  -- stylua: ignore
  -- unit quaterion, the element at [1,1] is 1, not affecting calculation, thus omited
  return matrix.new(3, 3, {
    1 - 2 * (j * j + k * k), 2 * (i * j - r * k), 2 * (i * k + r * j),
    2 * (i * j + r * k), 1 - 2 * (i * i + k * k), 2 * (j * k - r * i),
    2 * (i * k - r * j), 2 * (j * k + r * i), 1 - 2 * (i * i + j * j),
  })
end

---@param p Vector 3d
function Quaternion:rotatepos(p)
  local mat = self:matrix()
  return mat:mul(p)
end

-- rotate a by b
---@param a Quaternion
---@param b Quaternion
---@return Quaternion
function Quaternion.__mul(a, b)
  local v = vector.new(3, a.i, a.j, a.k)
  local v1 = b:matrix():mul(v)
  return Quaternion.new(a.r, v1[1], v1[2], v1[3])
end

return Quaternion
