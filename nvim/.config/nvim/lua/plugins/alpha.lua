return {
    "goolord/alpha-nvim",
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        dashboard.section.header.val = {
            [[          ▀████▀▄▄              ▄█ ]],
            [[            █▀    ▀▀▄▄▄▄▄    ▄▄▀▀█ ]],
            [[    ▄        █          ▀▀▀▀▄  ▄▀  ]],
            [[   ▄▀ ▀▄      ▀▄              ▀▄▀  ]],
            [[  ▄▀    █     █▀   ▄█▀▄      ▄█    ]],
            [[  ▀▄     ▀▄  █     ▀██▀     ██▄█   ]],
            [[   ▀▄    ▄▀ █   ▄██▄   ▄  ▄  ▀▀ █  ]],
            [[    █  ▄▀  █    ▀██▀    ▀▀ ▀▀  ▄▀  ]],
            [[   █   █  █      ▄▄           ▄▀   ]],
            -- "            :h-                                  Nhy`               ",
            -- "           -mh.                           h.    `Ndho               ",
            -- "           hmh+                          oNm.   oNdhh               ",
            -- "          `Nmhd`                        /NNmd  /NNhhd               ",
            -- "          -NNhhy                      `hMNmmm`+NNdhhh               ",
            -- "          .NNmhhs              ```....`..-:/./mNdhhh+               ",
            -- "           mNNdhhh-     `.-::///+++////++//:--.`-/sd`               ",
            -- "           oNNNdhhdo..://++//++++++/+++//++///++/-.`                ",
            -- "      y.   `mNNNmhhhdy+/++++//+/////++//+++///++////-` `/oos:       ",
            -- " .    Nmy:  :NNNNmhhhhdy+/++/+++///:.....--:////+++///:.`:s+        ",
            -- " h-   dNmNmy oNNNNNdhhhhy:/+/+++/-         ---:/+++//++//.`         ",
            -- " hd+` -NNNy`./dNNNNNhhhh+-://///    -+oo:`  ::-:+////++///:`        ",
            -- " /Nmhs+oss-:++/dNNNmhho:--::///    /mmmmmo  ../-///++///////.       ",
            -- "  oNNdhhhhhhhs//osso/:---:::///    /yyyyso  ..o+-//////////:/.      ",
            -- "   /mNNNmdhhhh/://+///::://////     -:::- ..+sy+:////////::/:/.     ",
            -- "     /hNNNdhhs--:/+++////++/////.      ..-/yhhs-/////////::/::/`    ",
            -- "       .ooo+/-::::/+///////++++//-/ossyyhhhhs/:///////:::/::::/:    ",
            -- "       -///:::::::////++///+++/////:/+ooo+/::///////.::://::---+`   ",
            -- "       /////+//++++/////+////-..//////////::-:::--`.:///:---:::/:   ",
            -- "       //+++//++++++////+++///::--                 .::::-------::   ",
            -- "       :/++++///////////++++//////.                -:/:----::../-   ",
            -- "       -/++++//++///+//////////////               .::::---:::-.+`   ",
            -- "       `////////////////////////////:.            --::-----...-/    ",
            -- "        -///://////////////////////::::-..      :-:-:-..-::.`.+`    ",
            -- "         :/://///:///::://::://::::::/:::::::-:---::-.-....``/- -   ",
            -- "           ::::://::://::::::::::::::----------..-:....`.../- -+oo/ ",
            -- "            -/:::-:::::---://:-::-::::----::---.-.......`-/.      ``",
            -- "           s-`::--:::------:////----:---.-:::...-.....`./:          ",
            -- "          yMNy.`::-.--::..-dmmhhhs-..-.-.......`.....-/:`           ",
            -- "         oMNNNh. `-::--...:NNNdhhh/.--.`..``.......:/-              ",
            -- "        :dy+:`      .-::-..NNNhhd+``..`...````.-::-`                ",
            -- "                        .-:mNdhh:.......--::::-`                    ",
            -- "                           yNh/..------..`                          ",
            -- "                                                                    ",
            "     Neovim for Developement",
        }

        dashboard.section.buttons.val = {
            dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
            dashboard.button("r", "  Recent", ":Telescope oldfiles<CR>"),
            dashboard.button("q", "  Quit", ":qa<CR>"),
        }

        dashboard.section.footer.val = "Config by Mohiitp — Web + Competitive + Blockchain "

        alpha.setup(dashboard.opts)
    end,
}
