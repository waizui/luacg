local bounds = require("render.bounds")

---@class Primitive
local Primitive = require("language").newclass("Primitive")

---@param r number row of data table eg. r=2,c=2 meaning 2x2 dataset
function Primitive:ctor(r, c, ...)
  self.r = r
  self.c = c
  ---@type Vector[]
  self.data = { ... }
  self.count = #self.data / (r * c)
end

---@param j number index of a primitive dataset
function Primitive.get(p, j)
  local d = {}

  local len = p.r * p.c
  for i = 1 + (j - 1) * len, j * len do
    table.insert(d, p.data[i])
  end
  return d
end

function Primitive.put(p, ...)
  local arg = { ... }
  local c, len = #arg, p.r * p.c
  for i = 1, c do
    table.insert(p.data, arg[i])
    if i % len == 0 then
      p.count = p.count + 1
    end
  end
end

---@return Bounds
function Primitive.bounds(p)
  --TODO: caching
  ---@type Bounds
  local b = bounds.new()
  for i = 1, p.count do
    local vert = p:get(i)
    for j = 1, p.c do
      b = b:encapsulate(vert[j])
    end
  end

  return b
end

---@param p Primitive
function Primitive.centroid(p)
  return p:bounds():centroid()
end

return Primitive
