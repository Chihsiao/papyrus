local fs = require 'fs'

md_figure_resolvers['mermaid'] =
    function (title, _, content, attrs)
        local attributes = Attributes.parse(attrs)
        local opts = {}

        if attributes.id ~= nil then
            opts.name = attributes.id:gsub(':', '-')
        end

---@diagnostic disable-next-line: undefined-global
        local output_file = image.mmdc(opts)(content)
        return '!['..title..']('..output_file..')'..attrs
    end
