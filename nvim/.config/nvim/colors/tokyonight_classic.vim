hi clear
syntax reset
let g:colors_name = "tokyonight_classic"

if &background == "dark"
    hi Normal       gui=NONE guifg=#c0caf5 guibg=#1a1b26
    hi Comment      gui=italic guifg=#565f89 guibg=NONE
    hi Constant     gui=NONE guifg=#ff9e64 guibg=NONE
    hi String       gui=NONE guifg=#9ece6a guibg=NONE
    hi Character    gui=NONE guifg=#9ece6a guibg=NONE
    hi Number       gui=NONE guifg=#ff9e64 guibg=NONE
    hi Boolean      gui=NONE guifg=#ff9e64 guibg=NONE
    hi Float        gui=NONE guifg=#ff9e64 guibg=NONE

    hi Identifier   gui=NONE guifg=#c0caf5 guibg=NONE
    hi Function     gui=NONE guifg=#7aa2f7 guibg=NONE

    hi Statement    gui=NONE guifg=#bb9af7 guibg=NONE
    hi Conditional  gui=NONE guifg=#bb9af7 guibg=NONE
    hi Repeat       gui=NONE guifg=#bb9af7 guibg=NONE
    hi Label        gui=NONE guifg=#bb9af7 guibg=NONE
    hi Operator     gui=NONE guifg=#89ddff guibg=NONE
    hi Keyword      gui=NONE guifg=#bb9af7 guibg=NONE
    hi Exception    gui=NONE guifg=#bb9af7 guibg=NONE

    hi PreProc      gui=NONE guifg=#7dcfff guibg=NONE
    hi Include      gui=NONE guifg=#7dcfff guibg=NONE
    hi Define       gui=NONE guifg=#7dcfff guibg=NONE
    hi Macro        gui=NONE guifg=#7dcfff guibg=NONE

    hi Type         gui=NONE guifg=#2ac3de guibg=NONE
    hi StorageClass gui=NONE guifg=#2ac3de guibg=NONE
    hi Structure    gui=NONE guifg=#2ac3de guibg=NONE
    hi Typedef      gui=NONE guifg=#2ac3de guibg=NONE

    hi Special      gui=NONE guifg=#89ddff guibg=NONE
    hi Underlined   gui=underline guifg=#7aa2f7 guibg=NONE
    hi Todo         gui=bold guifg=#1a1b26 guibg=#e0af68

    hi CursorLine   gui=NONE guibg=#24283b
    hi CursorColumn gui=NONE guibg=#24283b
    hi ColorColumn  gui=NONE guibg=#24283b
    hi LineNr       gui=NONE guifg=#3b4261
    hi CursorLineNr gui=bold guifg=#7aa2f7

    hi StatusLine   gui=NONE guifg=#c0caf5 guibg=#24283b
    hi StatusLineNC gui=NONE guifg=#565f89 guibg=#24283b

    hi VertSplit    gui=NONE guifg=#414868 guibg=NONE
    hi Visual       gui=NONE guibg=#364a82
    hi Search       gui=NONE guifg=#1a1b26 guibg=#e0af68
    hi IncSearch    gui=NONE guifg=#1a1b26 guibg=#ff9e64

    hi Pmenu        gui=NONE guifg=#c0caf5 guibg=#24283b
    hi PmenuSel     gui=NONE guifg=#1a1b26 guibg=#7aa2f7

    hi Error        gui=NONE guifg=#f7768e guibg=NONE
    hi WarningMsg   gui=NONE guifg=#e0af68 guibg=NONE
endif
