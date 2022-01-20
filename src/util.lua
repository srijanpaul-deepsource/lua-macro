local lfs = require "lfs"
local path = require "path"
local json = require "lib.json"
local io = require "io"

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
                util.crawl_dir(f)
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

  print(json_string)
  local data = json.decode(json_string)
  return data
end

util.issue_code_map = util.load_issue_codes()

--- Converts a luacheck issue object into a deepsource compatible issue object
--- @param lc_issue table An issue table returned by luacheck.
--- @param file_path string The source file where the issue was reported.
--- @param issue_text string The issue text to render.
--- @return table
function util.luacheck_issue_to_ds_issue(lc_issue, file_path, issue_text)
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

return util
