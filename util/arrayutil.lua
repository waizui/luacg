local lang = require("language")

---@class ArrayUtil
local ArrayUtil = lang.newclass("ArrayUtil")

function ArrayUtil.slice(arr, s, e)
  local t = {}
  table.move(arr, s, e, 1, t)
  return t
end

---@param comparer function
---@return number
function ArrayUtil.partition(arr, s, e, comparer)
  local l, r = s - 1, e + 1

  while true do
    while true do
      l = l + 1
      if comparer(arr[l]) then
        break
      end
      if l == e then
        break
      end
    end

    while true do
      r = r - 1
      if not comparer(arr[r]) then
        break
      end
      if r == s then
        break
      end
    end

    if l >= r then
      break
    end
    arr[l], arr[r] = arr[r], arr[l]
  end

  return r
end

return ArrayUtil
