-- 2d array arithmetic operations
local Op = {}

local scalatable = {
  __index = function(t, k)
    return t.v
  end,
}

local function isnum(a)
  return type(a) == "number"
end

-- move number to the right if any is number
local function numtoright(a, b)
  if isnum(a) then
    a, b = b, a
  end
  -- syntax candy, scala b as a table
  if isnum(b) then
    return a, setmetatable({ v = b }, scalatable)
  end

  return a, b
end

function Op.add(m, a, b)
  a, b = numtoright(a, b)
  for i = 1, a.r * a.c do
    m[i] = a[i] + b[i]
  end
  return m
end

function Op.sub(m, a, b)
  local exchanged = isnum(a)
  a, b = numtoright(a, b)
  for i = 1, a.r * a.c do
    m[i] = (exchanged and b[i] - a[i]) or a[i] - b[i]
  end
  return m
end

function Op.scale(m, a, b)
  a, b = numtoright(a, b)
  m.r = a.r
  m.c = a.c
  for i = 1, a.r * a.c do
    m[i] = b[i] * a[i]
  end
  return m
end

function Op.div(m, a, b)
  local exchanged = isnum(a)
  a, b = numtoright(a, b)
  m.r = a.r
  m.c = a.c
  for i = 1, a.r * a.c do
    m[i] = (exchanged and b[i] / a[i]) or a[i] / b[i]
  end
  return m
end

function Op.cross(m, a, b)
  if a.r == 3 then
    return Op.cross3d(m, a, b)
  elseif a.r == 2 then
    return Op.cross2d(a, b)
  end

  error("4d cross not implemented", -1)
end

function Op.cross3d(m, u, v)
  m[1] = u[2] * v[3] - u[3] * v[2]
  m[2] = u[3] * v[1] - u[1] * v[3]
  m[3] = u[1] * v[2] - u[2] * v[1]
  return m
end

function Op.cross2d(u, v)
  return u[1] * v[2] - u[2] * v[1]
end

function Op.dot(m, a, b)
  for i = 1, a.r do
    for j = 1, b.c do
      local acc = 0
      for k = 1, b.r do
        local m1i = (i - 1) * a.c + k
        local m2i = (k - 1) * b.c + j
        acc = acc + (a[m1i] or 0) * (b[m2i] or 0)
      end
      m[(i - 1) * m.c + j] = acc
    end
  end

  if a.c == 1 then
    return m[1]
  end

  return m
end

return Op
