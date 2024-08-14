local lang = require("language")

local A = lang.newclass("A")

function A:ctor()
  print("ctorA")
end

function A:foo()
  print("fooA")
end

local B = lang.newclass("B", "A")
function B:ctor()
  print("ctorB")
end

function B:foo()
  print("fooB")
end

function B:bar()
  print("bar")
end

local C = lang.newclass("C", "B")

function C:ctor()
  print("ctorC")
end

function B:foo()
  print("fooC")
end

function B:zoo()
  print("zoo")
end

local a = A.new()
a:foo()

local b = B.new()
b:foo()

local c = C.new()

c:foo()

print("test pased")
