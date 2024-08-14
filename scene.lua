local barycentric_coordinates = require("examples.examplebarycentric")
local raycast = require("examples.exampleraycast")
local rotation = require("examples.examplequaternion")

local repl = function()
  local str = {
    "please select what to render",
    " [1]: rasterisation and  barycentric coordinates",
    " [2]: naive path tracing",
    " [3]: rotation",
  }
  print(table.concat(str, "\n"))

  local i = io.read("*n")
  print("processing...")
  local size = 128
  if i == 1 then
    barycentric_coordinates(size, size)
  elseif i == 2 then
    raycast(size, size)
  elseif i == 3 then
    rotation(size, size)
  else
    print("no such selection")
  end
end

repl()

print("finished")
