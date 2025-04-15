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
    fs.write(metadata_file, json.encode(metadata, {indent=true})..'\n')
end

---@diagnostic disable-next-line: undefined-global
atexit(write_metadata)
