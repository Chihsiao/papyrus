---@diagnostic disable: lowercase-global

---Get content and type of fence
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
