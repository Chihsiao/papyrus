---
title: '这里是标题'
author: '这里是作者'

subfigGrid: true
codeBlockCaptions: true

figureTitle: 图
figPrefix: 图

tableTitle: 表
tblPrefix: 表

listingTitle: 项
lstPrefix: 项
---

@@[[
    new_page = [=[```{=openxml}
<w:p><w:r><w:br w:type="page"/></w:r></w:p>
```]=]
]]

@@[[
    function custom_style(style, content)
        return [=[::: {custom-style="]=]..style..[=["}]=]..
            "\n| "..content.."\n"..
            [=[:::]=]
    end

    function indentless(content)
        return custom_style("Indentless", content)
    end

    function centered(content)
        return custom_style("Centered", content)
    end
]]

@@[[
    function cite(key)
        return "@" .. key
    end
]]

@include "org.md"
