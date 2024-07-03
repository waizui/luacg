local Lang = require("language")

---@class RefValue
local RefValue = Lang.newclass("RefValue")

---@param v any
function RefValue:ctor(v)
  self._v = v
end

---@param v any
function RefValue:set(v)
  self._v = v
end

function RefValue:get()
  return self._v
end

function RefValue.isnumber(a)
  return type(a) == "number"
end

function RefValue.__mul(a, b)
  local d = 0
  if RefValue.isnumber(b) then
    d = b
  else
    d = b._v
  end

  a._v = a._v * d
  return a
end

function RefValue.__div(a, b)
  local d = 0
  if RefValue.isnumber(b) then
    d = b
  else
    d = b._v
  end

  a._v = a._v / d
  return a
end

function RefValue.__add(a, b)
  local d = 0
  if RefValue.isnumber(b) then
    d = b
  else
    d = b._v
  end

  a._v = a._v + d
  return a
end

function RefValue.__sub(a, b)
  local d = 0
  if RefValue.isnumber(b) then
    d = b
  else
    d = b._v
  end

  a._v = a._v - d
  return a
end

function RefValue.__eq(a, b)
  local d = 0
  if RefValue.isnumber(b) then
    d = b
  else
    d = b._v
  end

  return a._v == d
end

return RefValue
