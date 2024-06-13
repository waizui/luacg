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

function Language.newclass(name, supername)
  local class = {}
  return Language.regclass(class, name, supername)
end

function Language.regclass(class, name, supername)
  if classes[name] then
    error("class already exists :" .. name, 2)
    return
  end

  classes[name] = class
  class._clsname = name
  supername = supername or "Object"
  class._base = supername

  local super = classes[supername]
  setmetatable(class, super)
  class.__index = findfield

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
