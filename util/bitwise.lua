-- compatible with old lua

local bit = {}

local function to32bit(n)
  return n & 0xFFFFFFFF
end

bit.band = function(a, b)
  return to32bit(a & b)
end

bit.bor = function(a, b)
  return to32bit(a | b)
end

bit.bxor = function(a, b)
  return to32bit(a ~ b)
end

bit.bnot = function(a)
  return to32bit(~a)
end

bit.lshift = function(a, b)
  return to32bit(a << b)
end

bit.rshift = function(a, b)
  return to32bit(a >> b)
end

return bit
