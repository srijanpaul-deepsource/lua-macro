_G.is_local_run = ({...})[1] == "-local"

local luacheck = require "luacheck"
local env = require "src.env"
local util = require "src.util"

local function run_analysis()
  local code_dir = env.CODE_PATH
  local code_files = util.crawl_dir(code_dir)

  local lua_files = {}
  for _, fpath in ipairs(code_files) do
    local ext = fpath:sub(-3)
    if ext == "lua" then
      lua_files[#lua_files + 1] = fpath
    end
  end

  print("Files for analysis: ")
  for _, file_name in ipairs(lua_files) do
    print(file_name)
  end

  local reports = luacheck(lua_files)
  for i, report in ipairs(reports) do
    local file_path = lua_files[i]
    report.file_path = file_path:sub(#code_dir + 2, #file_path)
  end

  return reports
end

local reports = run_analysis()
local report = util.generate_ds_report(reports)
print('Number of issues reported: ', #report.issues)
util.publish_report(report)
