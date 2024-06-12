local lang = require("language")
local op = require("structures.operation")

-- local Vector = {
-- 	dot = M.mul,
-- 	scale = M.scale,
-- 	add = M.add,
-- }

local Vector = lang.newclass("Vector")

function Vector:ctor(r, ...)
	local args = { ... }
	self.c = 1
	self.r = r
	for i, v in ipairs(args) do
		self[i] = v
	end
end

function Vector.__mul(a, b)
	local v = Vector.new(a.r)
	return op.scale(v, a, b)
end

function Vector.__add(a, b)
	local v = Vector.new(a.r)
	return op.add(v, a, b)
end

function Vector:cross(v) end

function Vector:dot(v) end

return Vector
