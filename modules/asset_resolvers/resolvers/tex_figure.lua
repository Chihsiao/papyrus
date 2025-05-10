local sh = require 'sh'
local crypt = require 'crypt'
local fs = require 'fs'

---@type string
---@diagnostic disable-next-line: undefined-global
local aux_root_dir = fs.join(fs.dirname(ypp.output_file()), 'aux')

---@diagnostic disable-next-line: undefined-global
asset_resolvers['.fig.tex'] = setmetatable({
    latexmk = function (...)
        return sh.read('latexmk', ...)
    end,
}, {
    __call = function (self, title, src, _, attrs)
---@diagnostic disable-next-line: undefined-global
        local input_path = ypp.find_file(src)
        local output_dir = fs.dirname(input_path)
        local parsed_attrs = Attributes.parse(attrs)
        local output_basename = fs.basename(input_path):sub(1, -5)
        local output_path = fs.join(output_dir, output_basename..'.pdf')
        local aux_name = (parsed_attrs.id or crypt.hash(src)):gsub(':', '-')
        local aux_dir = fs.join(aux_root_dir, aux_name)

        local latexmk_args = {
            "-synctex=1",
            "-file-line-error",
            "-interaction=nonstopmode",
            "-jobname="..output_basename,
            "-outdir="..output_dir,
            "-auxdir="..aux_dir,
            input_path,
        }

        fs.with_dir(fs.dirname(input_path), function ()
            if not self.latexmk(table.unpack(latexmk_args)) then
---@diagnostic disable-next-line: undefined-global
                ypp.error "diagram error"
            end
        end)

        return resolve('!['..title..']('..output_path..')'..attrs)
    end
})
