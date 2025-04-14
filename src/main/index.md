---
title: '这里是标题'
author: '这里是作者'

subfigGrid: true
linkReferences: true
codeBlockCaptions: true

figureTitle: 图
figPrefix: 图

tableTitle: 表
tblPrefix: 表

listingTitle: 项
lstPrefix: 项
---

<!--
@@[[
    function from_fence(input)
        local output = {}
        local capturing = false
        local extracted_value = nil

        for line in input:gmatch("([^\n]*)\n?") do
            if not capturing then
                local matched = line:match("^```(%w+)$")
                if matched then
                    extracted_value = matched
                    capturing = true
                end
            else
                if line:match("^```$") then
                    break
                end
                table.insert(output, line)
            end
        end

        return table.concat(output, "\n"), extracted_value
    end
]]
-->

<!--
@@[[load(from_fence([==[
-->
```lua
    new_page = [=[```{=openxml}
<w:p><w:r><w:br w:type="page"/></w:r></w:p>
```]=]

    function custom_style(style, content)
        return [=[::: {custom-style="]=]..style..[=["}]=]..
            "\n| "..content.."\n"..
            [=[:::]=]
    end
```
<!--
]==]))()]]
-->

<!--
@@[[load(from_fence([=[
-->
```lua
    function ref(key)
        return "@" .. key
    end
```
<!--
]=]))()]]
-->

@include "org.md"
