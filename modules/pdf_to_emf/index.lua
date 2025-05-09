local sh = require 'sh'
local crypt = require 'crypt'
local fs = require 'fs'
local F = require 'F'

---@type string
---@diagnostic disable-next-line: undefined-global
local output_dir = fs.join(fs.dirname(ypp.output_file()), 'img')

---@diagnostic disable-next-line: undefined-global
asset_resolvers['.pdf'] = setmetatable({
    inkscape = function (...)
        return sh.read('inkscape', ...)
    end,
}, {
    __call = function (self, title, src, file_content, attrs)
        local attributes = Attributes.parse(attrs)

        local hash = crypt.hash(file_content)
        local output_basename = hash

        if attributes.id ~= nil then
            output_basename = attributes.id:gsub(':', '-')
        end

        local output_path = fs.join(output_dir, output_basename..'.emf')
        local output_meta_path = output_path..'.meta'
        local meta_content = F.unlines {
            'hash: '..hash
        }

        local old_meta = fs.read(output_meta_path) or ''
---@diagnostic disable-next-line: undefined-global
        local input_path = ypp.find_file(src)

        if not fs.is_file(output_path) or meta_content ~= old_meta then
            local inkscape_args = {'--pdf-poppler', '--export-type=emf',
                '--export-filename='..output_path,
                '--', input_path
            }

            fs.mkdirs(fs.dirname(output_path))
            if not self.inkscape(table.unpack(inkscape_args)) then
    ---@diagnostic disable-next-line: undefined-global
                ypp.error "diagram error"
            end

            fs.write(output_meta_path, meta_content)
        end

        return resolve('!['..title..']('..output_path..')'..attrs)
    end
})
