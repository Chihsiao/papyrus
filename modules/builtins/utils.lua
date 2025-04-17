---@diagnostic disable: lowercase-global

local F = require 'F'

---Extract content and type from code fence
---@param input string
---@return string
---@return string | nil
function from_fence(input)
    local output = {}
    local capturing = false
    local extracted_value = nil

    for line in input:gmatch('([^\n]*)\n?') do
        if not capturing then
            local matched = line:match('^```(%w+)$')
            if matched then
                extracted_value = matched
                capturing = true
            end
        else
            if line:match('^```$') then
                break
            end
            table.insert(output, line)
        end
    end

    return table.concat(output, '\n'), extracted_value
end

---Apply paragraph with custom style
---@param style string
---@param para string
---@return string
local function use_custom_style(style, para)
    return '::: {custom-style="'..style..'"}\n'..
---@diagnostic disable-next-line: undefined-global
           '| '..ypp(content)..'\n'..
           ':::'
end

custom_style = F.curry(use_custom_style)
