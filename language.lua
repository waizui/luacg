local Language = {}

local classes = {}

local findfield = function(self, k)
  local clsname = self._clsname
  while true do
    local cls = classes[clsname]
    if not cls then
      return
    end

    local val = rawget(cls, k)

    if val ~= nil then
      rawset(self, k, val)
      return val
    end

    clsname = cls._base
  end
end

local Object = {
  _clsname = "Object",
  _base = nil,
  __index = findfield,
}

classes["Object"] = Object

---@param name string class name
---@param super table|nil super Class
function Language.newclass(name, super)
  local class = {}
  return Language.regclass(class, name, super)
end

---@param class table class to be registgered
---@param name string class name
---@param super table|nil super Class
function Language.regclass(class, name, super)
  if classes[name] then
    error("class already exists :" .. name, 2)
    return
  end

  super = super or Object
  classes[name] = class
  class._clsname = name
  class._base = super._clsname
  class.__index = findfield
  setmetatable(class, super)

  class.new = function(...)
    local ins = {}
    ins._clsname = name
    ins.__index = findfield
    setmetatable(ins, class)
    -- class with constructor
    if ins.ctor then
      ins:ctor(...)
    end
    return ins
  end
  return class
end

return Language
