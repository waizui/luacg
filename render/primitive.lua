local bounds = require("render.bounds")

---@class Primitive
---@field count number number of dataset
---@field r number rows of data table
---@field c number columns of data table
---@field data table store dataset use the structure of data table definied by row and column
local Primitive = require("language").newclass("Primitive")

--TODO: index array of dataset

--[[
  first row is vertex , following rows could be other properties
  e.g r=2,c=2 meaning 2x2 dataset for a line
  [vertex1,vertex2,
  uv1,uv2]

  r = 2, c=3 for a triangle
  [vertex1,vertex2, vertex3
  uv1,uv2, uv3]
]]
---@param r number rows of dataset
---@param c number columns of dataset
function Primitive:ctor(r, c, ...)
  self.r = r
  self.c = c
  ---@type Vector[]
  self.data = { ... }
  self.count = #self.data / (r * c)
end

---@param j number index of a primitive dataset
---@param p Primitive
---@return table --flatten dataset at index j
function Primitive.get(p, j)
  local d = {}

  local len = p.r * p.c
  for i = 1 + (j - 1) * len, j * len do
    table.insert(d, p.data[i])
  end
  return d
end

---@param p Primitive
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

--TODO: unify calling method
---@return Bounds
function Primitive.bounds(p)
  if p._bounds then
    return p._bounds
  end
  ---@type Bounds
  local b = bounds.new()
  for i = 1, p.count do
    local vert = p:get(i)
    for j = 1, p.c do
      b = b:encapsulate(vert[j])
    end
  end

  p._bounds = b

  return b
end

---@param p Primitive
function Primitive.centroid(p)
  return p:bounds():centroid()
end

---@param p Primitive
function Primitive.normal(p)
  return p._normal or p:trianglenormal()
end

function Primitive:trianglenormal(p)
  local d = self:get(1)
  local p1, p2, p3 = d[1], d[2], d[3]
  local n = (p2 - p1):cross(p3 - p1):normalize()
  return n
end

return Primitive
