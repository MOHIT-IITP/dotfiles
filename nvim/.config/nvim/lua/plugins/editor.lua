return {
    {
        "windwp/nvim-ts-autotag",
        ft = {
            "html",
            "javascript",
            "javascriptreact",
            "typescriptreact",
            "svelte",
            "vue",
            "xml",
        },
        opts = {
            enable_close = true,
            enable_rename = true,
            enable_close_on_slash = true,
        },
    },

    -- Auto-close brackets, quotes
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
            check_ts = true,
        },
        config = function(_, opts)
            local autopairs = require("nvim-autopairs")
            autopairs.setup(opts)
        end,
    },
    {
        "Wansmer/treesj",
        keys = { "<space>m", "<space>j", "<space>s" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("treesj").setup({})
        end,
    },
    {
        "echasnovski/mini.surround",
        version = false,
        event = "VeryLazy",

        opts = {
            custom_surroundings = nil,

            highlight_duration = 500,

            mappings = {
                add = "sa",
                delete = "sd",
                find = "sf",
                find_left = "sF",
                highlight = "sh",
                replace = "sr",

                suffix_last = "l",
                suffix_next = "n",
            },

            n_lines = 20,

            respect_selection_type = false,

            search_method = "cover",

            silent = false,
        },

        config = function(_, opts)
            require("mini.surround").setup(opts)
        end,
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function()
            require("notify").setup({
                stages = "fade_in_slide_out",
                timeout = 2000,
            })

            require("noice").setup({
                lsp = {
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true,
                    },
                },
                presets = {
                    bottom_search = true, -- search bar at bottom
                    command_palette = true, -- position cmdline & popupmenu together
                    long_message_to_split = true, -- long messages in split
                    inc_rename = false,
                    lsp_doc_border = true,
                },
            })
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },

        config = function()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true,        -- single statusline for all windows
                    icons_enabled = true,
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = { "neo-tree", "alpha" },
                },

                sections = {
                    lualine_a = { "mode" },

                    lualine_b = {
                        { "branch", icon = "" },
                        { "diff" },
                    },

                    lualine_c = {
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = {
                                error = " ",
                                warn  = " ",
                                info  = " ",
                                hint  = "󰌵 ",
                            },
                        },
                        {
                            "filename",
                            path = 1,                -- 0 = filename, 1 = relative, 2 = absolute
                            symbols = { modified = " ", readonly = " " },
                        },
                    },

                    lualine_x = {
                        {
                            function()
                                local buf_ft = vim.bo.filetype
                                local clients = vim.lsp.get_clients({ bufnr = 0 })
                                if next(clients) == nil then
                                    return ""
                                end

                                local names = {}
                                for _, client in ipairs(clients) do
                                    table.insert(names, client.name)
                                end

                                return "  " .. table.concat(names, ", ")
                            end,
                            color = { fg = "#a6e3a1" },
                        },
                        "encoding",
                        "filetype",
                        "recording",
                    },

                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },

                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
            })
        end,
    },
}
