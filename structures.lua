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

function M.inverse(m)
  -- argument matrix
  local am = {}
  am.c = m.c
  am.r = m.r
  M.inherit(am, M.T_matrixr4x4)
  for i = 1, m.c do
    am:set(i, i, 1)
  end

  for c = 1, m.c do
    for r = c, m.r do
      M.eliminate(m, am, r, c)
    end
  end

  --TODO: bottom to top

  return am
end

function M.eliminate(m, am, sr, sc) --start row , stat col
  for r = sr + 1, m.r do
    local cur = m:get(r, sc)
    if not cur or cur == 0 then
      if r ~= sr then
        M.swaprow(m, sr, r)
        M.swaprow(am, sr, r)
      end
      break
    end
  end

  local base = m:get(sr, sc)
  if not base or base == 0 then
    return
  end

  for r = sr + 1, m.r do
    M.addrow(m, sr, r)
    M.addrow(am, sr, r)
  end

  return m, am
end

function M.addrow(m, r1, r2)
  local row1 = m:getrow(r1)
  local row2 = m:getrow(r2)

  local factor = -(row2[1] or 0) / row1[1]

  for i = 1, m.c do
    if row1[i] then
      row2[i] = row1[i] * factor + (row2[i] or 0)
    end
  end

  m:setrow(r2, row2)
end

function M.swaprow(m, r1, r2)
  local tr1 = m:getrow(r1)
  local tr2 = m:getrow(r2)

  m:setrow(r1, tr2)
  m:setrow(r2, tr1)
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
  setmetatable(m, m1)
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
  get = function(self, r, c)
    -- index start from 1
    return self[(r - 1) * self.c + c]
  end,
  set = function(self, r, c, v)
    self[(r - 1) * self.c + c] = v
  end,
  getrow = function(self, r)
    local row = {}
    for i = 1, self.c do
      row[i] = self:get(r, i)
    end
    return row
  end,
  setrow = function(self, r, ...)
    for i, v in ipairs(...) do
      self:set(r, i, v)
    end
  end,
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
