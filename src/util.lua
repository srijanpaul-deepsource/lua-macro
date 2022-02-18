local lfs = require "lfs"
local path = require "path"
local json = require "lib.json"
local io = require "io"
local luacheck = require "luacheck"
local env = require "src.env"
local os = require "os"

local util = {}

--- Recursively crawls a directory, returning the list of filenames inside it.
---@param dir_path string The directory name to recurse on.
---@return table
function util.crawl_dir(dir_path, result)
    result = result or {}

    for file in lfs.dir(dir_path) do
        if file ~= "." and file ~= ".." then
            local f = path.join(dir_path, file)
            local attr = lfs.attributes(f)
            assert(type(attr) == "table")
            if attr.mode == "directory" then
                local sub_dir_files = util.crawl_dir(f)
                for _, file in ipairs(sub_dir_files) do
                  result[#result + 1] = file
                end
            else
                result[#result + 1] = f
            end
        end
    end

    return result
end

function util.load_issue_codes()
  local cwd = path.currentdir()
  local issue_map_path = path.join(cwd, "src", "config", "issues.json")
  local f = io.open(issue_map_path, "r")
  assert(f, string.format("issues config does not exist at '%s'", issue_map_path))
  local json_string = f:read("*a")
  f:close()

  -- print(json_string)
  local data = json.decode(json_string)
  return data
end

util.issue_code_map = util.load_issue_codes()

--- Converts a luacheck issue object into a deepsource compatible issue object
--- @param lc_issue table An issue table returned by luacheck.
--- @param file_path string The source file where the issue was reported.
--- @param issue_text string The issue text to render.
--- @return table
function util.lc_issue_to_ds_issue(lc_issue, file_path, issue_text)
  local start_line = lc_issue.prev_line or lc_issue.line
  local start_column = lc_issue.prev_end_column or lc_issue.end_column

  local end_line = lc_issue.line
  local end_column = lc_issue.end_column

  local location = {
    path = file_path,
    position = {
      begin  = { line = start_line, column = start_column },
      ["end"] = { line = end_line, column = end_column },
    }
  }

  return {
    location = location,
    issue_code = util.issue_code_map[lc_issue.code],
    issue_text = issue_text
  }
end

--- Get a list of deepsource issues from a luacheck report.
--- @param lc_reports table A list of reports returned by Luacheck.
function util.get_ds_issues_from_lc_report(lc_reports)
  local issues = {}
  for _, report in ipairs(lc_reports) do
    for _, issue in ipairs(report) do
      local message = luacheck.get_message(issue)
      local ds_issue = util.lc_issue_to_ds_issue(issue, report.file_path, message)
      issues[#issues + 1] = ds_issue
    end
  end
  return issues
end

function util.generate_ds_report(reports)
  local issues = util.get_ds_issues_from_lc_report(reports)
  return {
    issues = issues,
    errors = {},
    metrics = {},
  }
end

--- Writes the deepsource report string into the analysis_reports.json file and gets marvin to publish it
---@param ds_report string The final deepsource report object
function util.publish_report(ds_report)
  local result_path = string.format(path.join("%s", "analysis_results.json"), env.TOOLBOX_PATH)

  -- 1. write the report into a JSON file:
  local f = io.open(result_path, "w")
  if not f then
    print("Failed to open ", result_path)
    return
  end
  f:write(json.encode(ds_report))
  f:close()

  -- 2. call marvin and publish the result
  local publish_command = string.format("%s/marvin --publish-report %s", env.TOOLBOX_PATH, result_path)
  local exit_code = os.execute(publish_command)
  if exit_code ~= 0 then
    print("Failed to publish report with marvin")
  end
end

return util
