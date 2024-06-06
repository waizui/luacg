local data = require("structures")

local M = {}

function M.camera(p, v, near, far, fov, aspect)
	-- TODO: world to viewspace transform

	p = p or data.vec3(0, 0, 1)
	v = v or data.vec3(0, 0, -1)
	near = near or 0.25
	far = far or 4
	fov = fov or 0.8
	aspect = aspect or 1

	local h = near * fov
	local w = h / aspect
	local m00 = (2 * near) / w
	local m02 = 0 -- l+r = 0
	local m11 = (2 * near) / h
	local m12 = 0
	local m22 = (far + near) / (near - far)
	local m23 = (2 * far * near) / (near - far)
	local m32 = -1

	---@class camera
	local camera = {
		pos = p,
		dir = v,
		near = near,
		far = far,
		fov = fov,
		aspect = aspect or 1,
		matrixVP = data.matrixr4x4(m00, 0, m02, 0, 0, m11, m12, 0, 0, 0, m22, m23, 0, 0, m32, 0),
	}

	return camera
end

return M
