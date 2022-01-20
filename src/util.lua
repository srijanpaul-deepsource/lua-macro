local lfs = require "lfs"
local path = require "path"

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


return util
