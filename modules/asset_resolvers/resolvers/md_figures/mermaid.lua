local fs = require 'fs'

md_figure_resolvers['mermaid'] =
    function (title, src, content, ...)
        local filename = fs.basename(src)
        local basename = filename:sub(1, ((filename:find('%.') or 0) - 1))

---@diagnostic disable-next-line: undefined-global
        local target = image.mmdc({name = basename})(content)
        return '!['..title..']('..target..')'..(...)
    end
