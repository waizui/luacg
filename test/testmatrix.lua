local data = require("structures.structure")

local M = {}

function M.test_inverse()
	local matrice = {
    -- stylua: ignore
    data.mat4x4(
      1, 0, 0, 0,
      1, 2, 0, 0,
      1, 2, 3, 0,
      1, 2, 3, 4),

    -- stylua: ignore
    data.mat4x4(
      1, 2, 3, -4.3,
      9, 2, 1.8, 4,
      3, 2.78, 3, 4,
      0, 0, 3.3, 4),

    -- stylua: ignore
    data.mat4x4(
      -2.5, 2.5, -2.5,
      0.359375, -2.5, 2.5, 2.5,
      -0.390625, 4, 6.266666, 6.266666,
      -1, 1, 1, 1, 0),
	}

	for _, m in ipairs(matrice) do
		local inv = data.inverse(m)
		local im = inv:mul(m)
		for i = 1, im.r do
			assert(math.abs(im:get(i, i)) - 1 < 1e-10)
		end
	end
end

M.test_inverse()
print("test pased")
