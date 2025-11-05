require("config.keymaps")
require("config.autocmds")

-- load Lazy.nvim from config/lazy.lua
local lazy = require("config.lazy")
lazy.setup("plugins")
