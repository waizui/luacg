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
  m.r, m.c = m1.r, m2.c
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

function M.matrixcopy(om)
  local m = {}
  m.r, m.c = om.r, om.c
  M.inherit(m, M.T_matrixr4x4)
  for r = 1, m.r do
    for c = 1, m.c do
      m:set(r, c, om:get(r, c))
    end
  end

  return m
end

function M.inverse(om)
  local m = M.matrixcopy(om)
  -- argument matrix
  local am = {}
  am.c, am.r = m.c, m.r
  M.inherit(am, M.T_matrixr4x4)
  for c = 1, m.c do
    am:set(c, c, 1)
  end

  for c = 1, m.c do
    M.eliminate(m, am, c, c)
  end

  for c = m.c, 1, -1 do
    M.reveliminate(m, am, c, c)
  end

  for r = 1, m.r do
    local diag = m:get(r, r)
    M.scalerow(am, r, 1 / diag)
  end

  return am
end

function M.scalerow(m, r, factor)
  for i = 1, m.c do
    local v = m:get(r, i)
    if v and v ~= 0 then
      m:set(r, i, v * factor)
    else
      m:set(r, i, 0)
    end
  end
end

function M.eliminate(m, am, sr, sc) --start row , stat col
  -- make first element none zero
  local first = m:get(sr, sc)
  if not first or first == 0 then
    for r = sr + 1, m.r do
      local cur = m:get(r, sc)
      if not cur or cur == 0 then
        M.swaprow(m, sr, r)
        M.swaprow(am, sr, r)
        break
      end
    end
  end

  local base = m:get(sr, sc)
  if not base or base == 0 then
    return
  end

  for r = sr + 1, m.r do
    M.addrow(m, am, sr, r, sc)
  end
end

function M.reveliminate(m, am, sr, sc) -- reverse-eliminate
  local first = m:get(sr, sc)
  if not first or first == 0 then
    for r = sr - 1, 1, -1 do
      local cur = m:get(r, sc)
      if not cur or cur == 0 then
        M.swaprow(m, r, sr)
        M.swaprow(am, r, sr)
        break
      end
    end
  end

  local base = m:get(sr, sc)
  if not base or base == 0 then
    return
  end

  for r = sr - 1, 1, -1 do
    M.addrow(m, am, sr, r, sc)
  end

  return m, am
end

function M.addrow(m, am, r1, r2, c)
  local row1, row2 = m:getrow(r1), m:getrow(r2)

  local nume = row2[c] or 0

  if nume == 0 then
    return
  end

  local factor = -nume / row1[c]

  local amrow1, amrow2 = am:getrow(r1), am:getrow(r2)

  for i = 1, m.c do
    if row1[i] and row1[i] ~= 0 then
      row2[i] = row1[i] * factor + (row2[i] or 0)
    end

    if amrow1[i] and amrow1[i] ~= 0 then
      local a, b = amrow2[i], amrow1[i]
      amrow2[i] = amrow1[i] * factor + (amrow2[i] or 0)
    end
  end

  m:setrow(r2, row2)
  am:setrow(r2, amrow2)
end

function M.swaprow(m, r1, r2)
  local tr1, tr2 = m:getrow(r1), m:getrow(r2)

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

function M.scale(m, factor)
  for i = 1, m.r * m.c do
    m[i] = factor * m[i]
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
    return self[(r - 1) * self.c + c] or 0
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
