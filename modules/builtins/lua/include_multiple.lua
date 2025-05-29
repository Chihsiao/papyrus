local fs = require 'fs'

---Include multiple files
---@param glob string
---@param opts table
---@return table
---@diagnostic disable-next-line: lowercase-global
function include_multiple(glob, opts)
    local addressed = setmetatable({}, {
        __tostring = function (self)
            local stringified = {}

            for _, included in ipairs(self) do
                local included_file = included.s
                    :gsub("\\", "\\\\"):gsub("\'", "\\\'")
                io.stderr:write("@include '"..included_file.."'\n")
                table.insert(stringified, tostring(included))
            end

            return table.concat(stringified, '\n')
        end
    })

---@diagnostic disable-next-line: undefined-global
    local dir = fs.dirname(ypp.input_file())
    local files = fs.ls(fs.join(dir, glob))

    for _, file in ipairs(files) do
---@diagnostic disable-next-line: undefined-global
        local included = include(file, opts)
        table.insert(addressed, included)
    end

    return addressed
end
