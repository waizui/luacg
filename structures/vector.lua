local lang = require("language")
local op = require("structures.operation")

---@class Vector
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

---@return Vector
function Vector.__add(a, b)
	local v = Vector.new(a.r)
	return op.add(v, a, b)
end

function Vector.__sub(a, b)
	local v = Vector.new(a.r)
	return op.sub(v, a, b)
end

function Vector:cross(v)
	local c = Vector.new(self.r)
	return op.cross(c, self, v)
end

function Vector:dot(v)
	local c = Vector.new(self.r)
	return op.dot(c, self, v)
end

return Vector
