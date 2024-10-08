local function openOpenGL()
  local has, gl = pcall(require, "luagl")
  if not has then
    print("your Lua interpreter is not support luagl.")
    return
  end

  print("starting...")

  -- window needs to be initialized first
  local win = gl.Window.new(512, 512)

  -- stylua: ignore
  local vertices = {
    1, 1, 0.0,
    1, -1, 0.0,
    -1, -1, 0.0,
    -1, 1, 0.0
  }

  -- stylua: ignore
  local indices = {
    0, 1, 3,
    1, 2, 3
  }

  local vert = io.open("./shaders/vertex.vert", "r"):read("*a")
  local frag = io.open("./shaders/fragment.frag", "r"):read("*a")

  local shader = gl.Shader.new(vert, frag)
  local rc = gl.RenderContext.new(shader, vertices, indices)

  win:show(rc)
  win:close()
end

return openOpenGL
