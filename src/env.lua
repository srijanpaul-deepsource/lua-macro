local lfs = require "lfs"
local json = require "lib.json"
local path = require "path"
local os = require "os"

local cwd = lfs.currentdir()

local is_local_run = true
local env
if is_local_run then
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
