local data = require "structures"

local M = {}


function M.test_inverse()

  -- local m1 = data.matrixr4x4(
  --   1, 0, 0, 0,
  --   1, 2, 0, 0,
  --   1, 2, 3, 0,
  --   1, 2, 3, 4)
  --
  -- local im = data.inverse(m1):mul(m1)
  --
  -- for i=1,im.r do
  --   assert(im:get(i,i) == 1)
  -- end
  --
  -- local m2 = data.matrixr4x4(
  --   1, 2, 3, -4.3,
  --   9, 2, 1.8, 4,
  --   3, 2.78, 3, 4,
  --   0, 0, 3.3, 4)
  --
  -- local inv = data.inverse(m2)
  -- im = inv:mul(m2)
  -- for i=1,im.r do
  --   assert((im:get(i,i) - 1)<1e-10)
  -- end


  local m3 = data.matrixr4x4(
    -2.5, 2.5, 2.5, -0.234375,
    -2.5, 2.5, 2.5, -0.390625,
    4, 6.266666, 6.266666, -1,
    1, 1, 1, 0)

  --[[
    0	-0.24303782086213869484	0.094936648774272927671	0.01265885274756155218
	0.2	-0.025822692517283216909	0.056961989264563756603	0.20759531164853693131
	-0.2	0.26886051337942191175	-0.15189863803883668427	0.77974583560390151651
	0	0.55088410703537529406	-1.2151891043106934742	6.2379666848312121321
  ]]

  local inv = data.inverse(m3)
  local im = inv:mul(m3)
  for i=1,im.r do
    if (im:get(i,i) - 1)<1e-10 then
      print("fail")
    end
    assert((im:get(i,i) - 1)<1e-10)
  end
end


M.test_inverse()
