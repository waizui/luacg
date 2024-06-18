---@class Primitives
local Primitives = require("language").newclass("Primitives")

---@param r number row of data table eg. r=2,c=2 meaning 2x2 dataset
function Primitives:ctor(r, c, ...)
  self.r = r
  self.c = c
  self.data = { ... }
  self.count = #self.data / (r * c)
end

---@param j number index of a primitive dataset
function Primitives.get(p, j)
  local d = {}

  local len = p.r * p.c
  for i = 1 + (j - 1) * len, j * len do
    table.insert(d, p.data[i])
  end
  return d
end

function Primitives.put(p, ...)
  local arg = { ... }
  local c, len = #arg, p.r * p.c
  for i = 1, c do
    table.insert(p.data, arg[i])
    if i % len == 0 then
      p.count = p.count + 1
    end
  end
end

return Primitives
