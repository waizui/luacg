local M = {}

function M.inherit(m1, m2)
  setmetatable(m1, { __index = m2 })
end

function M.vec2(x, y)
  ---@class vec2
  local m = {
    [1] = x,
    [2] = y,
  }
  m.r = 2
  m.c = 1
  m.cross = M.cross2d
  M.inherit(m, M.T_vector)
  return m
end

function M.vec3(x, y, z)
  ---@class vec3
  local m = {
    [1] = x,
    [2] = y,
    [3] = z,
  }
  m.r = 3
  m.c = 1
  m.cross = M.cross3d
  M.inherit(m, M.T_vector)
  return m
end

function M.vec4(x, y, z, w)
  ---@class vec4
  local m = {
    [1] = x,
    [2] = y,
    [3] = z,
    [4] = w,
  }

  m.r = 4
  m.c = 1
  M.inherit(m, M.T_vector)
  return m
end

-- matrix multiplication
function M.mul(m1, m2)
  local m = {}
  m.r = m1.r
  m.c = m2.c
  M.inherit(m, M.T_matrixr4x4)
  for i = 1, m1.r do
    for j = 1, m2.c do
      local acc = 0
      for k = 1, m2.r do
        local m1i = (i - 1) * m1.c + k
        local m2i = (k - 1) * m2.c + j
        acc = acc + (m1[m1i] * m2[m2i])
      end
      m[(i - 1) * m.c + j] = acc
    end
  end

  return m
end

function M.cross3d(u, v)
  local m = {
    u[2] * v[3] - u[3] * v[2],
    u[3] * v[1] - u[1] * v[3],
    u[1] * v[2] - u[2] * v[1],
  }
  M.inherit(m, M.T_vector)
  return m
end

function M.cross2d(u, v)
  return u[1] * v[2] - u[2] * v[1]
end

function M.scale(m, scala)
  for i = 1, m.r * m.c do
    m[i] = scala * m[i]
  end

  return m
end

function M.add(m1, m2)
  local m = {}
  for i = 1, m1.r * m1.c do
    m[i] = m1[i] + m2[i]
  end
  setmetatable(m,m1)
  return m
end

function M.print_matrix(m)
  local t = ""
  for i in ipairs(m) do
    t = t .. m[i]
    if i % 4 == 0 then
      print(t)
      t = ""
    end
  end
end

M.T_matrixr4x4 = {
  mul = M.mul,
  print = M.print_matrix,
  scale = M.scale,
}

M.T_vector = {
  dot = M.mul,
  scale = M.scale,
  add = M.add,
}

function M.matrixr4x4(...)
  ---@class matrix4x4
  local m = { ... }
  M.inherit(m, M.T_matrixr4x4)
  m.r = 4
  m.c = 4
  return m
end

return M
