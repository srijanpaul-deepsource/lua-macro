local lfs = require "lfs"
local json = require "lib.json"
local path = require "path"
local os = require "os"

local env
if _G.is_local_run then
  local cwd = lfs.currentdir()
  env = {
    CODE_PATH = path.join(cwd, "code-dir")
  }
else
  env = {
    CODE_PATH = os.getenv("CODE_PATH"),
    TOOLBOX_PATH = os.getenv("TOOLBOX_PATH")
  }
end

return env
