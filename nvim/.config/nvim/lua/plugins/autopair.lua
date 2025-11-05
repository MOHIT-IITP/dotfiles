return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
        local npairs = require("nvim-autopairs")
        local Rule = require("nvim-autopairs.rule")

        npairs.setup({
            check_ts = true, -- enable treesitter integration
            ts_config = {
                lua = { "string" }, -- don't add pairs in lua strings
                javascript = { "template_string" },
                java = false, -- disable treesitter check for java
            },
            fast_wrap = {
                map = "<M-e>", -- Alt+e to wrap existing text
                chars = { "{", "[", "(", '"', "'" },
                pattern = [=[[%'%"%>%]%)%}%,]]=],
                offset = 0, -- Offset from pattern match
                end_key = "$",
                keys = "qwertyuiopzxcvbnmasdfghjkl",
                check_comma = true,
                highlight = "PmenuSel",
                highlight_grey = "LineNr",
            },
            disable_filetype = { "TelescopePrompt", "vim" },
            enable_check_bracket_line = true, -- Don’t add a pair if next char is a closing
            break_line_filetype = nil,  -- disable smart enter
            ignored_next_char = "[%w%.]", -- Ignore alphanumeric and dot
        })

        ---------------------------------------------------------------------------
        -- 💡 Integration with nvim-cmp (for auto-insertion after completion)
        ---------------------------------------------------------------------------
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp_status, cmp = pcall(require, "cmp")
        if cmp_status then
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end

        ---------------------------------------------------------------------------
        -- ⚙️ Custom Rules for Development + Competitive Programming
        ---------------------------------------------------------------------------

        -- Auto add space between ( and )
        npairs.add_rules({
            Rule(" ", " ")
                :with_pair(function(opts)
                    local pair = opts.line:sub(opts.col - 1, opts.col)
                    return vim.tbl_contains({ "()", "{}", "[]" }, pair)
                end),
        })

        -- Add < > pairing (useful for templates in C++, generics in Java)
        npairs.add_rules({
            Rule("<", ">")
                :with_pair(function(opts)
                    local prev_char = opts.line:sub(opts.col - 1, opts.col - 1)
                    if prev_char:match("[%w%)]") then
                        return false
                    end
                    return true
                end)
                :with_move(function(opts)
                    return opts.prev_char:match(".%>") ~= nil
                end)
                :use_key(">"),
        })
    end,
}
