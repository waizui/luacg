local data = require "structures"

local M = {}


function M.test_inverse()

  local m1 = data.matrixr4x4(
    1, 0, 0, 0,
    1, 2, 0, 0,
    1, 2, 3, 0,
    1, 2, 3, 4)

  local im = data.inverse(m1):mul(m1)

  for i=1,im.r do
    assert(im:get(i,i) == 1)
  end

  local m2 = data.matrixr4x4(
    1, 2, 3, -4.3,
    9, 2, 1.8, 4,
    3, 2.78, 3, 4,
    0, 0, 3.3, 4)

  local inv = data.inverse(m2)
  im = inv:mul(m2)
  for i=1,im.r do
    assert((im:get(i,i) - 1)<1e-10)
  end
end


M.test_inverse()
