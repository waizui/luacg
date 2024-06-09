local data = require "structures"

local M = {}


function M.test_inverse()

  local mb = data.matrixr4x4(
    1, 0, 0, 0,
    1, 2, 0, 0,
    1, 2, 3, 0,
    1, 2, 3, 4)

  local im = data.inverse(mb)
  im:print()

  -- local mt = data.matrixr4x4(
  --   1, 2, 3, 4,
  --   0, 2, 3, 4,
  --   0, 0, 3, 4,
  --   0, 0, 0, 4)
  --
  -- local im = data.inverse(mt)
  -- im:print()
end


M.test_inverse()
