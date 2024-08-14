local quaternion = require("structures.quaternion")
local vector = require("structures.vector")

local function testrotatevector()
  local r = quaternion.angle(45, vector.new(3, 1, 1, 1))
  local rr = quaternion.angle(-45, vector.new(3, 1, 1, 1))

  local vec = vector.new(3, 0, 1, 0)

  local to = r:rotatevec(vec)

  local res = rr:rotatevec(to)
  assert(res == vec)
end

local function testrotatequaternion()
  local r = quaternion.angle(45, vector.new(3, 1, 1, 1))
  local rr = quaternion.angle(-45, vector.new(3, 1, 1, 1))

  local vec = vector.new(3, 0, 1, 0)
  local to = r * rr
  local res = to:rotatevec(vec)
  assert(res == vec)
end

testrotatevector()
testrotatequaternion()

print("quaternion test passed")
