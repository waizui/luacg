local Vector = require("structures.vector")

---@class Sampler
local Sampler = require("language").newclass("Sampler")

--uniformly sample a hemisphere
---@return Vector,number -- dir,pdf
function Sampler.hemiphere()
  local phi = 2 * math.pi * math.random()
  local rand = math.random()

  -- sin(arccos(x)) = square root of 1 - x^2
  local sinthta = math.sqrt(1 - rand * rand)

  local x = math.cos(phi) * sinthta
  local y = math.sin(phi) * sinthta
  local z = phi

  local dir = Vector.new(3, x, y, z)

  return dir:normalize(), 0.5 * math.pi
end

return Sampler
