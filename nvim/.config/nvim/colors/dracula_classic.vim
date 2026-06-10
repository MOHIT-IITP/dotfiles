hi clear
syntax reset
let g:colors_name = "dracula_classic"

if &background == "dark"
    hi Normal       gui=NONE guifg=#f8f8f2 guibg=#282a36
    hi Comment      gui=italic guifg=#6272a4 guibg=NONE

    hi Constant     gui=NONE guifg=#ffb86c guibg=NONE
    hi String       gui=NONE guifg=#50fa7b guibg=NONE
    hi Character    gui=NONE guifg=#50fa7b guibg=NONE
    hi Number       gui=NONE guifg=#ffb86c guibg=NONE
    hi Boolean      gui=NONE guifg=#ffb86c guibg=NONE
    hi Float        gui=NONE guifg=#ffb86c guibg=NONE

    hi Identifier   gui=NONE guifg=#f8f8f2 guibg=NONE
    hi Function     gui=NONE guifg=#8be9fd guibg=NONE

    hi Statement    gui=NONE guifg=#ff79c6 guibg=NONE
    hi Conditional  gui=NONE guifg=#ff79c6 guibg=NONE
    hi Repeat       gui=NONE guifg=#ff79c6 guibg=NONE
    hi Label        gui=NONE guifg=#ff79c6 guibg=NONE
    hi Operator     gui=NONE guifg=#8be9fd guibg=NONE
    hi Keyword      gui=NONE guifg=#ff79c6 guibg=NONE
    hi Exception    gui=NONE guifg=#ff5555 guibg=NONE

    hi PreProc      gui=NONE guifg=#bd93f9 guibg=NONE
    hi Include      gui=NONE guifg=#bd93f9 guibg=NONE
    hi Define       gui=NONE guifg=#bd93f9 guibg=NONE
    hi Macro        gui=NONE guifg=#bd93f9 guibg=NONE

    hi Type         gui=NONE guifg=#8be9fd guibg=NONE
    hi StorageClass gui=NONE guifg=#f1fa8c guibg=NONE
    hi Structure    gui=NONE guifg=#8be9fd guibg=NONE
    hi Typedef      gui=NONE guifg=#8be9fd guibg=NONE

    hi Special      gui=NONE guifg=#bd93f9 guibg=NONE
    hi Underlined   gui=underline guifg=#8be9fd guibg=NONE
    hi Todo         gui=bold guifg=#282a36 guibg=#f1fa8c

    hi CursorLine   gui=NONE guibg=#343746
    hi CursorColumn gui=NONE guibg=#343746
    hi ColorColumn  gui=NONE guibg=#343746

    hi LineNr       gui=NONE guifg=#44475a
    hi CursorLineNr gui=bold guifg=#ff79c6

    hi StatusLine   gui=NONE guifg=#f8f8f2 guibg=#343746
    hi StatusLineNC gui=NONE guifg=#6272a4 guibg=#343746

    hi VertSplit    gui=NONE guifg=#44475a guibg=NONE
    hi Visual       gui=NONE guibg=#44475a

    hi Search       gui=NONE guifg=#282a36 guibg=#f1fa8c
    hi IncSearch    gui=NONE guifg=#282a36 guibg=#ffb86c

    hi Pmenu        gui=NONE guifg=#f8f8f2 guibg=#343746
    hi PmenuSel     gui=NONE guifg=#282a36 guibg=#8be9fd

    hi Error        gui=NONE guifg=#ff5555 guibg=NONE
    hi WarningMsg   gui=NONE guifg=#f1fa8c guibg=NONE
endif
