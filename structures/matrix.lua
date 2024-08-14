local lang = require("language")
local op = require("structures.operation")
local epsilon = require("util.mathutil").epsilon

---@class Matrix
local Matrix = lang.newclass("Matrix")

function Matrix:ctor(r, c, ...)
  local args = { ... }
  if #args == 1 then
    args = args[1]
  end
  self.c = c
  self.r = r
  for i, v in ipairs(args) do
    self[i] = v
  end
end

function Matrix.__mul(a, b)
  local v = Matrix.new(a.r)
  return op.scale(v, a, b)
end

function Matrix.__div(a, b)
  local v = Matrix.new(a.r)
  return op.scale(v, a, 1 / b)
end

---@return Vector
function Matrix.__add(a, b)
  local v = Matrix.new(a.r)
  return op.add(v, a, b)
end

function Matrix.__sub(a, b)
  local v = Matrix.new(a.r)
  return op.sub(v, a, b)
end

function Matrix.set(m, r, c, v)
  m[(r - 1) * m.c + c] = v
end

function Matrix.get(m, r, c)
  return m[(r - 1) * m.c + c] or 0
end

function Matrix.scale(a, factor)
  local m = Matrix.new(a.r, a.c)
  return op.scale(m, a, factor)
end

function Matrix.getrow(m, r)
  local row = {}
  for i = 1, m.c do
    row[i] = m:get(r, i)
  end
  return row
end

function Matrix.setrow(m, r, ...)
  for i, v in ipairs(...) do
    m:set(r, i, v)
  end
end

---@return Matrix
function Matrix.mul(m1, m2)
  local m = Matrix.new(m1.r, m2.c)
  return op.dot(m, m1, m2)
end

function Matrix.copy(om)
  local m = Matrix.new(om.r, om.c)
  for r = 1, m.r do
    for c = 1, m.c do
      m:set(r, c, om:get(r, c))
    end
  end

  return m
end

---@return Matrix
function Matrix.transpose(om)
  local m = Matrix.new(om.r, om.c)

  for c = 1, m.c do
    for r = 1, m.r do
      m:set(r, c, om:get(c, r))
    end
  end

  return m
end

function Matrix.inverse(om)
  local m = Matrix.copy(om)
  -- argument matrix
  local am = Matrix.new(m.c, m.r)
  for c = 1, m.c do
    am:set(c, c, 1)
  end

  for c = 1, m.c do
    Matrix.eliminate(m, am, c, c)
  end

  for c = m.c, 1, -1 do
    Matrix.reveliminate(m, am, c, c)
  end

  for r = 1, m.r do
    local diag = m:get(r, r)
    Matrix.scalerow(am, r, 1 / diag)
  end

  return am
end

function Matrix.scalerow(m, r, factor)
  for i = 1, m.c do
    local v = m:get(r, i)
    if v then
      if math.abs(v - 0) < epsilon then
        m:set(r, i, 0)
      else
        m:set(r, i, v * factor)
      end
    else
      m:set(r, i, 0)
    end
  end
end

function Matrix.iszero(n)
  return (not n) or (math.abs(n) <= epsilon)
end

function Matrix.eliminate(m, am, sr, sc) --start row , stat col
  -- make first element none zero
  local first = m:get(sr, sc)
  if Matrix.iszero(first) then
    for r = sr + 1, m.r do
      local cur = m:get(r, sc)
      if not Matrix.iszero(cur) then
        Matrix.swaprow(m, sr, r)
        Matrix.swaprow(am, sr, r)
        break
      end
    end
  end

  local base = m:get(sr, sc)
  if Matrix.iszero(base) then
    return
  end

  for r = sr + 1, m.r do
    Matrix.addrow(m, am, sr, r, sc)
  end
end

function Matrix.reveliminate(m, am, sr, sc) -- reverse-eliminate
  local first = m:get(sr, sc)
  if Matrix.iszero(first) then
    for r = sr - 1, 1, -1 do
      local cur = m:get(r, sc)
      if Matrix.iszero(cur) then
        Matrix.swaprow(m, r, sr)
        Matrix.swaprow(am, r, sr)
        break
      end
    end
  end

  local base = m:get(sr, sc)
  if Matrix.iszero(base) then
    return
  end

  for r = sr - 1, 1, -1 do
    Matrix.addrow(m, am, sr, r, sc)
  end

  return m, am
end

function Matrix.addrow(m, am, r1, r2, c)
  local row1, row2 = m:getrow(r1), m:getrow(r2)

  local nume = row2[c]

  if Matrix.iszero(nume) then
    return
  end

  local factor = -nume / row1[c]

  local amrow1, amrow2 = am:getrow(r1), am:getrow(r2)

  for i = 1, m.c do
    if not Matrix.iszero(row1[i]) then
      row2[i] = row1[i] * factor + (row2[i] or 0)
    end

    if not Matrix.iszero(amrow1[i]) then
      amrow2[i] = amrow1[i] * factor + (amrow2[i] or 0)
    end
  end

  m:setrow(r2, row2)
  am:setrow(r2, amrow2)
end

function Matrix.swaprow(m, r1, r2)
  local tr1, tr2 = m:getrow(r1), m:getrow(r2)

  m:setrow(r1, tr2)
  m:setrow(r2, tr1)
end

function Matrix.identity(d)
  local m = Matrix.new(d, d)
  for i = 1, d do
    m[(i - 1) * d + i] = 1
  end

  return m
end

function Matrix.translate(d, ...)
  local m = Matrix.identity(d)
  for i, v in ipairs({ ... }) do
    m[i * d] = v
  end
  return m
end

return Matrix
