---@diagnostic disable: lowercase-global

local F = require 'F'

new_page = [[```{=openxml}
<w:p><w:r><w:br w:type="page"/></w:r></w:p>
```]]

local function use_custom_style(style, content)
    return '::: {custom-style="'..style..'"}\n'..
---@diagnostic disable-next-line: undefined-global
           '| '..ypp(content)..'\n'..
           ':::'
end

custom_style = F.curry(use_custom_style)
