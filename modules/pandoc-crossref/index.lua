---@diagnostic disable: lowercase-global

pandoc_crossref = {
    i18n = setmetatable({
        zh_CN = {
            figureTitle="图", figPrefix="图",
            listingTitle="项", lstPrefix="项",
            tableTitle="表", tblPrefix="表",
        },
    }, {
        ---@param self any
        ---@param locate string
        __call = function (self, locate)
            metadata(self[locate])
        end,
    }),
}

function ref(key)
    return '@' .. key
end
