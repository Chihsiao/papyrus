---@diagnostic disable: lowercase-global

local fs = require 'fs'
local json = require 'json'

metadata = setmetatable({}, {
    __jsontype = 'object',
    __jsonorder = {
        'title', 'author', 'date',
        'subtitle', 'abstract', 'abstract-title',
        'keywords', 'subject', 'description',
        'category',
    },
    ---@param self any
    ---@param other table
    __call = function (self, other)
        for k, v in pairs(other) do
            self[k] = v
        end
    end,
})

local function write_metadata()
---@diagnostic disable-next-line: undefined-global
    local metadata_file = ypp.output_file()..'.json'
    local content = json.encode(metadata, {indent=true})..'\n'
    fs.mkdirs(fs.dirname(metadata_file))
    fs.write(metadata_file, content)
end

---@diagnostic disable-next-line: undefined-global
atexit(write_metadata)
