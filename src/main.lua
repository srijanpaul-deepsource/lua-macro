local luacheck = require "luacheck"
local env = require "src.env"
local util = require "src.util"
local json = require "lib.json"

local function run_analysis()
  local code_dir = env.CODE_PATH
  local code_files = util.crawl_dir(code_dir)

  local reports = luacheck(code_files)
  return reports
end

local reports <const> = run_analysis()
for _, report in ipairs(reports) do
  for _, issue in ipairs(report) do
    local message = luacheck.get_message(issue)
    local ds_issue = util.luacheck_issue_to_ds_issue(issue, "foo", message)
    local issue_json = json.encode(ds_issue)
    print(issue_json)
  end
end
