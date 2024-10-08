local vector = require("structures.vector")
local matrix = require("structures.matrix")
local primitive = require("render.primitive")

local M = {}

function M.inherit(m1, m2)
  setmetatable(m1, { __index = m2 })
end

function M.vec2(x, y)
  return vector.new(2, x, y)
end

---@return Vector
function M.vec3(x, y, z)
  return vector.new(3, x, y, z)
end

function M.vec4(x, y, z, w)
  return vector.new(4, x, y, z, w)
end

---@return Matrix
function M.mat4x4(...)
  return matrix.new(4, 4, ...)
end

---@param ... 123:vertex, 456:uv
---@return Primitive
function M.primitive(r,c,...)
  return primitive.new(r, c, ...)
end

return M
