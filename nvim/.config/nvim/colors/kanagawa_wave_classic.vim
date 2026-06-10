hi clear
syntax reset
let g:colors_name = "kanagawa_wave_classic"

if &background == "dark"
    hi Normal       gui=NONE guifg=#dcd7ba guibg=#1f1f28
    hi Comment      gui=italic guifg=#727169 guibg=NONE

    hi Constant     gui=NONE guifg=#ffa066 guibg=NONE
    hi String       gui=NONE guifg=#98bb6c guibg=NONE
    hi Character    gui=NONE guifg=#98bb6c guibg=NONE
    hi Number       gui=NONE guifg=#ffa066 guibg=NONE
    hi Boolean      gui=NONE guifg=#ffa066 guibg=NONE
    hi Float        gui=NONE guifg=#ffa066 guibg=NONE

    hi Identifier   gui=NONE guifg=#dcd7ba guibg=NONE
    hi Function     gui=NONE guifg=#7e9cd8 guibg=NONE

    hi Statement    gui=NONE guifg=#957fb8 guibg=NONE
    hi Conditional  gui=NONE guifg=#957fb8 guibg=NONE
    hi Repeat       gui=NONE guifg=#957fb8 guibg=NONE
    hi Label        gui=NONE guifg=#957fb8 guibg=NONE
    hi Operator     gui=NONE guifg=#c0a36e guibg=NONE
    hi Keyword      gui=NONE guifg=#957fb8 guibg=NONE
    hi Exception    gui=NONE guifg=#c34043 guibg=NONE

    hi PreProc      gui=NONE guifg=#7fb4ca guibg=NONE
    hi Include      gui=NONE guifg=#7fb4ca guibg=NONE
    hi Define       gui=NONE guifg=#7fb4ca guibg=NONE
    hi Macro        gui=NONE guifg=#7fb4ca guibg=NONE

    hi Type         gui=NONE guifg=#7aa89f guibg=NONE
    hi StorageClass gui=NONE guifg=#938056 guibg=NONE
    hi Structure    gui=NONE guifg=#7aa89f guibg=NONE
    hi Typedef      gui=NONE guifg=#7aa89f guibg=NONE

    hi Special      gui=NONE guifg=#e6c384 guibg=NONE
    hi Underlined   gui=underline guifg=#7e9cd8 guibg=NONE
    hi Todo         gui=bold guifg=#1f1f28 guibg=#e6c384

    hi CursorLine   gui=NONE guibg=#2a2a37
    hi CursorColumn gui=NONE guibg=#2a2a37
    hi ColorColumn  gui=NONE guibg=#2a2a37

    hi LineNr       gui=NONE guifg=#54546d
    hi CursorLineNr gui=bold guifg=#7e9cd8

    hi StatusLine   gui=NONE guifg=#dcd7ba guibg=#2a2a37
    hi StatusLineNC gui=NONE guifg=#727169 guibg=#2a2a37

    hi VertSplit    gui=NONE guifg=#363646 guibg=NONE
    hi Visual       gui=NONE guibg=#363646

    hi Search       gui=NONE guifg=#1f1f28 guibg=#e6c384
    hi IncSearch    gui=NONE guifg=#1f1f28 guibg=#ffa066

    hi Pmenu        gui=NONE guifg=#dcd7ba guibg=#2a2a37
    hi PmenuSel     gui=NONE guifg=#1f1f28 guibg=#7e9cd8

    hi Error        gui=NONE guifg=#c34043 guibg=NONE
    hi WarningMsg   gui=NONE guifg=#e6c384 guibg=NONE
endif
