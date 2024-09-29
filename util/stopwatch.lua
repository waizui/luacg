local lang = require("language")

---@class StopWatch
local StopWatch = lang.newclass("StopWatch")

function StopWatch:start()
  self.startTime = os.clock()
  self.running = true
end

function StopWatch:stop()
  if not self.running then
    return
  end

  self.endTime = os.clock()
  self.running = false
end

function StopWatch:elapsed()
  if self.running then
    return os.clock() - self.startTime
  elseif self.startTime and self.endTime then
    return self.endTime - self.startTime
  else
    return 0
  end
end

return StopWatch
