local lang = require("language")

---@class MathUtil
local MathUtil = lang.newclass("MathUtil")

MathUtil.epsilon = 1e-15

---@param a number
---@param b number
function MathUtil.approximate(a, b)
  a, b = (a or 0), (b or 0)
  return math.abs(a - b) <= MathUtil.epsilon
end

return MathUtil
