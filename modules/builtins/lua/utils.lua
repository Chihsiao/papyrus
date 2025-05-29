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

--#region Parser

---@class Parser
---@field text string
---@field pos integer
Parser = {}
Parser.__index = Parser

---@param text string
---@return Parser
function Parser.new(text)
    return setmetatable({
        text = text,
        pos = 1,
    }, Parser)
end

---@param len integer?
---@param skip integer?
---@return string
function Parser:peek(len, skip)
    skip = skip or 0
    len = len or 1
    local from = self.pos + skip
    return self.text:sub(from, from + len - 1)
end

---@param len integer?
---@return string
function Parser:shift(len)
    len = len or 1
    local from = self.pos
    local to = from + len - 1
    local ret = self.text:sub(from, to)
    self.pos = to + 1
    return ret
end

---@param text string
---@return boolean
function Parser:expect(text)
    if self:peek(#text) == text then
        self:shift(#text)
        return true
    end

    return false
end

---@param pattern string
---@return table | nil -- captured
function Parser:pattern_expect(pattern)
    local ret = table.pack((self.text):find('^'..pattern, self.pos))
    local s, e = table.unpack(ret, 1, 2)
    if s == nil then return nil end
    self.pos = e + 1
    return table.pack(table.unpack(ret, 3))
end

--#endregion

--#region Attributes

---@class Attributes
---@field id string | nil
---@field classes string[]
---@field properties table<string, string>
Attributes = {}
Attributes.__index = Attributes

---@return Attributes
function Attributes.new()
    return setmetatable({
        id = nil,
        classes = {},
        properties = {},
    }, Attributes)
end

---@return string | nil
local function parser__expect_string(self)
    local pos = self.pos

    local quote = self:shift()
    if quote ~= '"' then
        self.pos = pos
        return nil
    end

    local char = self:shift()
    local content = ''
    while #char > 0 do
        if char == quote then
            return content
        end

        if char == '\\' then
            char = self:shift()
            if #char == 0 then
                break
            end
        end

        content = content..char
        char = self:shift()
    end

    self.pos = pos
    return nil
end
--endregion

local AttrP = {
    WS = '%s+',
    ID = '#([%a%d-_:]+)',
    CLASS = '%.([%a%d-_]+)',
    PROP_KEY = '([%a%d-_:]+)=',
    PROP_BARE_VALUE = '([%a%d-_:%%]+)',
}

---@param descriptor string
function Attributes.parse(descriptor)
    local parser = Parser.new(descriptor)

    ---@type Attributes
    local attributes = Attributes.new()
    local start_expected = false

    while #parser:peek() > 0 do
        if parser:pattern_expect(AttrP.WS) then
            goto continue
        end

        if not start_expected then
            start_expected = parser:expect('{')
            if not start_expected then
                error("Expecting '{' at position "..parser.pos)
            end
        end

        if parser:expect('}') then return attributes end
        for _, t in ipairs { 'ID', 'CLASS', 'PROP_KEY' } do
            local captured = parser:pattern_expect(AttrP[t])
            if captured == nil then goto continue_expect end

            if t == 'ID' then
                attributes.id = captured[1]

            elseif t == 'CLASS' then
                table.insert(attributes.classes, captured[1])

            elseif t == 'PROP_KEY' then
                local c = parser:peek()
                if c ~= '"' then
                    local v_captured = parser:pattern_expect(AttrP.PROP_BARE_VALUE)
                    if v_captured == nil then error("Expecting a bare value at position "..parser.pos) end
                    attributes.properties[captured[1]] = v_captured[1]
                else
                    local v = parser__expect_string(parser)
                    if v == nil then error("Expecting a string at position "..parser.pos) end
                    attributes.properties[captured[1]] = v
                end
            end

            goto continue
            ::continue_expect::
        end

        error("Unexpected '"..parser:peek().."' at position "..parser.pos)
        ::continue::
    end

    return attributes
end

function Attributes:__tostring()
    local components = {}

    if self.id ~= nil then
        local comp_id = '#'..self.id
        assert(comp_id:match('^'..AttrP.ID..'$'))
        table.insert(components, comp_id)
    end

    for _, class in ipairs(self.classes) do
        local comp_class = '.'..class
        assert(comp_class:match('^'..AttrP.CLASS..'$'))
        table.insert(components, comp_class)
    end

    for key, value in pairs(self.properties) do
        local comp_prop_key = key..'='
        assert(comp_prop_key:match('^'..AttrP.PROP_KEY..'$'))
        local comp_prop_value = '"'..value:gsub('"', '\\"')..'"'
        local comp_prop = comp_prop_key..comp_prop_value
        table.insert(components, comp_prop)
    end

    return '{'..table.concat(components, ' ')..'}'
end

--#endregion

---Apply paragraph with custom style
---@param style string
---@param para string
---@return string
local function use_custom_style(style, para)
    return '::: {custom-style="'..style..'"}\n'..
---@diagnostic disable-next-line: undefined-global
            ypp(para)..'\n'..
           ':::'
end

custom_style = F.curry(use_custom_style)
