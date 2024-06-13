---@class BVH
local BVH = require("language").newclass("BVH")

---@param p Primitives
function BVH:ctor(p)
  self.primitives = p
end

function BVH.raycast(bvh, src, dir)
  --
end

-- moller trumbore raycast algorithm
---@param dir Vector
---@param src Vector
function BVH.mollertrumbore(src, dir, v1, v2, v3)
  ---@type Vector
  local e1, e2 = v2 - v1, v3 - v1
  --determinant of matrix [dir,e1,e2]
  local det = e1:dot(dir:cross(e2))

  -- ray parallel
  if math.abs(det) < 1e-19 then
    return
  end


  return true
end
