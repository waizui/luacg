local data = require("structures.structure")
local mathutil = require("util.mathutil")

local M = {}

function M.getmatrice()
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

  return matrice
end

function M.test_inverse()
  local matrice = M.getmatrice()

  for _, m in ipairs(matrice) do
    local inv = m:inverse()
    local im = inv:mul(m)
    for i = 1, im.r do
      assert(math.abs(im:get(i, i)) - 1 < 1e-10)
    end
  end
end

function M.test_operations()
  local pair = function(mat1, mat2, fun)
    for i = 1, mat1.r do
      for j = 1, mat1.c do
        local u, v = mat1:get(i, j), mat2:get(i, j)
        fun(u, v)
      end
    end
  end

  for _, mat in ipairs(M.getmatrice()) do
    -- mul
    local k = 0.5
    pair(mat, mat * k, function(u, v)
      assert(mathutil.approximate(u, v / k))
    end)

    pair(mat, k * mat, function(u, v)
      assert(mathutil.approximate(u, v / k))
    end)

    pair(mat, mat * mat, function(u, v)
      assert(mathutil.approximate(u * u, v))
    end)

    --div
    pair(mat, mat / mat, function(u, v)
      if tostring(v) == "nan" and u == 0 then
        return
      end
      assert(mathutil.approximate(v, 1))
    end)

    pair(mat, k / mat, function(u, v)
      assert(mathutil.approximate(u, 1 / (v / k)))
    end)

    pair(mat, mat / k, function(u, v)
      assert(mathutil.approximate(u, v * k))
    end)

    pair(mat, mat + k, function(u, v)
      assert(mathutil.approximate(u, v - k))
    end)

    pair(mat, k + mat, function(u, v)
      assert(mathutil.approximate(u, v - k))
    end)

    pair(mat, k - mat, function(u, v)
      assert(mathutil.approximate(u, k - v))
    end)

    pair(mat, mat - k, function(u, v)
      assert(mathutil.approximate(u, k + v))
    end)
  end
end

M.test_inverse()
M.test_operations()
print("test pased")
