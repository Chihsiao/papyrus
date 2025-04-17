---@diagnostic disable: lowercase-global

local fs = require 'fs'

---Get all possible extensions of filename
---@param filename string
---@return string[]
local function all_possible_extensions(filename)
    local extensions = {}

    for i = 1, #filename do
        if filename:sub(i, i) == '.' then
            table.insert(extensions, filename:sub(i))
        end
    end

    return extensions
end

asset_resolvers = {}

---Resolve resource by descriptor
---@param descriptor string
---@return string
function resolve(descriptor)
    ---@type string, string, string
    local title, src, attrs = descriptor:match('^%[(.-)%]%((.-)%)(.-)$')
    assert(attrs:len() == 0 or attrs:sub(1, 1) == '{' and attrs:sub(-1, -1) == '}')

    ---@type string
    local filename = fs.basename(src)
    local resolver = nil

    for _, suffix in ipairs(all_possible_extensions(filename)) do
        resolver = asset_resolvers[suffix]
        if resolver ~= nil then
            break
        end
    end

    assert(resolver ~= nil)

---@diagnostic disable-next-line: undefined-global
    local file_content = ypp.read_file(ypp.find_file(src))
    return resolver(title, src, file_content, attrs)
end
