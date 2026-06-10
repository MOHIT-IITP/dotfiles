hi clear
syntax reset
let g:colors_name = "catppuccin_mocha_classic"

if &background == "dark"
    hi Normal       gui=NONE guifg=#cdd6f4 guibg=#1e1e2e
    hi Comment      gui=italic guifg=#6c7086 guibg=NONE

    hi Constant     gui=NONE guifg=#fab387 guibg=NONE
    hi String       gui=NONE guifg=#a6e3a1 guibg=NONE
    hi Character    gui=NONE guifg=#a6e3a1 guibg=NONE
    hi Number       gui=NONE guifg=#fab387 guibg=NONE
    hi Boolean      gui=NONE guifg=#fab387 guibg=NONE
    hi Float        gui=NONE guifg=#fab387 guibg=NONE

    hi Identifier   gui=NONE guifg=#cdd6f4 guibg=NONE
    hi Function     gui=NONE guifg=#89b4fa guibg=NONE

    hi Statement    gui=NONE guifg=#cba6f7 guibg=NONE
    hi Conditional  gui=NONE guifg=#cba6f7 guibg=NONE
    hi Repeat       gui=NONE guifg=#cba6f7 guibg=NONE
    hi Label        gui=NONE guifg=#cba6f7 guibg=NONE
    hi Operator     gui=NONE guifg=#89dceb guibg=NONE
    hi Keyword      gui=NONE guifg=#cba6f7 guibg=NONE
    hi Exception    gui=NONE guifg=#f38ba8 guibg=NONE

    hi PreProc      gui=NONE guifg=#94e2d5 guibg=NONE
    hi Include      gui=NONE guifg=#94e2d5 guibg=NONE
    hi Define       gui=NONE guifg=#94e2d5 guibg=NONE
    hi Macro        gui=NONE guifg=#94e2d5 guibg=NONE

    hi Type         gui=NONE guifg=#94e2d5 guibg=NONE
    hi StorageClass gui=NONE guifg=#f9e2af guibg=NONE
    hi Structure    gui=NONE guifg=#94e2d5 guibg=NONE
    hi Typedef      gui=NONE guifg=#94e2d5 guibg=NONE

    hi Special      gui=NONE guifg=#f5c2e7 guibg=NONE
    hi Underlined   gui=underline guifg=#89b4fa guibg=NONE
    hi Todo         gui=bold guifg=#1e1e2e guibg=#f9e2af

    hi CursorLine   gui=NONE guibg=#313244
    hi CursorColumn gui=NONE guibg=#313244
    hi ColorColumn  gui=NONE guibg=#313244

    hi LineNr       gui=NONE guifg=#585b70
    hi CursorLineNr gui=bold guifg=#89b4fa

    hi StatusLine   gui=NONE guifg=#cdd6f4 guibg=#313244
    hi StatusLineNC gui=NONE guifg=#6c7086 guibg=#313244

    hi VertSplit    gui=NONE guifg=#45475a guibg=NONE
    hi Visual       gui=NONE guibg=#45475a

    hi Search       gui=NONE guifg=#1e1e2e guibg=#f9e2af
    hi IncSearch    gui=NONE guifg=#1e1e2e guibg=#fab387

    hi Pmenu        gui=NONE guifg=#cdd6f4 guibg=#313244
    hi PmenuSel     gui=NONE guifg=#1e1e2e guibg=#89b4fa

    hi Error        gui=NONE guifg=#f38ba8 guibg=NONE
    hi WarningMsg   gui=NONE guifg=#f9e2af guibg=NONE
endif
