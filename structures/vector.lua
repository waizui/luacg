local lang = require("language")
local op = require("structures.operation")
local mathutil = require("util.mathutil")

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

local function getempty(a, b)
  if type(a) == "number" then
    return Vector.new(b.r)
  end

  return Vector.new(a.r)
end

function Vector.__mul(a, b)
  local v = getempty(a, b)
  return op.scale(v, a, b)
end

function Vector.__div(a, b)
  local v = getempty(a, b)
  return op.div(v, a, b)
end

function Vector.__add(a, b)
  local v = getempty(a, b)
  return op.add(v, a, b)
end

function Vector.__sub(a, b)
  local v = getempty(a, b)
  return op.sub(v, a, b)
end

function Vector.__eq(a, b)
  for i = 1, a.r do
    if not mathutil.approximate(a[i], b[i]) then
      return false
    end
  end
  return true
end

function Vector.str(v)
  local str = {}
  for i = 1, v.r do
    table.insert(str, v[i])
  end
  return table.concat(str, ",")
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
---@return Vector
function Vector.normalize(a)
  local acc = 0
  for i = 1, a.r do
    acc = acc + a[i] * a[i]
  end
  return a / math.sqrt(acc)
end

function Vector.max(a, b)
  local v = Vector.new(a.r)
  for i = 1, a.r do
    local ai, bi = a[i], b[i]
    if ai > bi then
      v[i] = ai
    else
      v[i] = bi
    end
  end

  return v
end

function Vector.min(a, b)
  local v = Vector.new(a.r)
  for i = 1, a.r do
    local ai, bi = a[i], b[i]
    if ai > bi then
      v[i] = bi
    else
      v[i] = ai
    end
  end

  return v
end

function Vector.sqaremagnitude(v)
  local sum = 0
  for i = 1, v.r do
    sum = sum + v[i] * v[i]
  end
  return sum
end

function Vector.magnitude(v)
  return math.sqrt(v:sqaremagnitude())
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

function Vector.maxcomponent(v)
  local max = 1
  for i = 1, v.r do
    if v[i] > max then
      max = i
    end
  end

  return max
end

return Vector
