local data = require "structures"

local M = {}


function M.test_inverse()
  local m = data.matrixr4x4(
    1, 2, 3, 4,
    0, 2, 3, 4,
    0, 0, 3, 4,
    0, 0, 0, 4)

  local im = data.inverse(m)
  im:print()
end


M.test_inverse()
