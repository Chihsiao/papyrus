---@diagnostic disable: lowercase-global

md_figure_resolvers = setmetatable({}, {
    __call = function (self, title, src, file_content, attrs)
        local content, lang = from_fence(file_content)

        local resolver = self[lang]
        assert(resolver ~= nil)

        return resolver(title, src, content, attrs)
    end
})

asset_resolvers['.fig.md'] = md_figure_resolvers
