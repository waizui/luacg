local bit = {}

bit.band = function(a, b)
    return a & b
end

bit.bor = function(a, b)
    return a | b
end

bit.bxor = function(a, b)
    return a ~ b
end

bit.bnot = function(a)
    return ~a
end

bit.lshift = function(a, b)
    return a << b
end

bit.rshift = function(a, b)
    return a >> b
end

return bit

