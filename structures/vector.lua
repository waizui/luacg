local lang = require("language")
local op = require("structures.operation")

---@class Vector
local Vector = lang.newclass("Vector")

function Vector:ctor(r, ...)
  local args = { ... }
  self.c = 1
  self.r = r
  for i, v in ipairs(args) do
    self[i] = v
  end
end

function Vector.isnumber(a)
  return type(a) == "number"
end

---@return  Vector
function Vector.__mul(a, b)
  if not Vector.isnumber(b) then
    a, b = b, a
  end
  local v = Vector.new(a.r)
  return op.scale(v, a, b)
end

function Vector.__div(a, b)
  local v = Vector.new(a.r)
  return op.scale(v, a, 1 / b)
end

function Vector.__add(a, b)
  if not Vector.isnumber(b) then
    a, b = b, a
  end
  local v = Vector.new(a.r)
  return op.add(v, a, b)
end

function Vector.__sub(a, b)
  local v = Vector.new(a.r)
  return op.sub(v, a, b)
end

function Vector.cross(a, b)
  local v = Vector.new(a.r)
  return op.cross(v, a, b)
end

function Vector.dot(a, b)
  local v = Vector.new(a.r)
  return op.dot(v, a, b)
end

-- normalize a vector in itself
function Vector.normalize(a)
  local acc = 0
  for i = 1, a.r do
    acc = acc + a[i] * a[i]
  end
  return a / math.sqrt(acc)
end

function Vector.max(a, b)
  for i = 1, a.r do
    if a[i] > b[i] then
      return a
    end
  end

  return b
end

function Vector.min(a, b)
  local r = Vector.max(a, b)
  if r ~= a then
    return b
  end
  return a
end

---@param iter function
function Vector.foreach(v, iter)
  for i = 1, v.r do
    local cur = v[i]
    v[i] = iter(cur, i) or cur
  end
end

---@param v Vector
function Vector.toint(v)
  v:foreach(function(vi, i)
    return math.floor(vi + 0.5)
  end)

  return v
end

return Vector
