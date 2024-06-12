local vector = require("structures.vector")
local matrix = require("structures.matrix")

local M = {}

function M.inherit(m1, m2)
	setmetatable(m1, { __index = m2 })
end

function M.vec2(x, y)
	return vector.new(2, x, y)
end

function M.vec3(x, y, z)
	return vector.new(3, x, y, z)
end

function M.vec4(x, y, z, w)
	return vector.new(4, x, y, z, w)
end

---@return Matrix
function M.mat4x4(...)
	return matrix.new(4, 4, ...)
end

---@param ... 123:vertex, 456:uv
function M.primitive(...)
	local m = { ... }
	return m
end

function M.triangle(v1, v2, v3)
	return {
		[1] = v1,
		[2] = v2,
		[3] = v3,
		vertex = function(self)
			return self[1], self[2], self[3]
		end,
	}
end

return M
