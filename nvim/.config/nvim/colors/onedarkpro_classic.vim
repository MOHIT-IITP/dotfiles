hi clear
syntax reset
let g:colors_name = "onedarkpro_classic"

if &background == "dark"
    hi Normal       gui=NONE guifg=#abb2bf guibg=#282c34
    hi Comment      gui=italic guifg=#5c6370 guibg=NONE

    hi Constant     gui=NONE guifg=#d19a66 guibg=NONE
    hi String       gui=NONE guifg=#98c379 guibg=NONE
    hi Character    gui=NONE guifg=#98c379 guibg=NONE
    hi Number       gui=NONE guifg=#d19a66 guibg=NONE
    hi Boolean      gui=NONE guifg=#d19a66 guibg=NONE
    hi Float        gui=NONE guifg=#d19a66 guibg=NONE

    hi Identifier   gui=NONE guifg=#abb2bf guibg=NONE
    hi Function     gui=NONE guifg=#61afef guibg=NONE

    hi Statement    gui=NONE guifg=#c678dd guibg=NONE
    hi Conditional  gui=NONE guifg=#c678dd guibg=NONE
    hi Repeat       gui=NONE guifg=#c678dd guibg=NONE
    hi Label        gui=NONE guifg=#c678dd guibg=NONE
    hi Operator     gui=NONE guifg=#56b6c2 guibg=NONE
    hi Keyword      gui=NONE guifg=#c678dd guibg=NONE
    hi Exception    gui=NONE guifg=#e06c75 guibg=NONE

    hi PreProc      gui=NONE guifg=#56b6c2 guibg=NONE
    hi Include      gui=NONE guifg=#56b6c2 guibg=NONE
    hi Define       gui=NONE guifg=#56b6c2 guibg=NONE
    hi Macro        gui=NONE guifg=#56b6c2 guibg=NONE

    hi Type         gui=NONE guifg=#56b6c2 guibg=NONE
    hi StorageClass gui=NONE guifg=#e5c07b guibg=NONE
    hi Structure    gui=NONE guifg=#56b6c2 guibg=NONE
    hi Typedef      gui=NONE guifg=#56b6c2 guibg=NONE

    hi Special      gui=NONE guifg=#61afef guibg=NONE
    hi Underlined   gui=underline guifg=#61afef guibg=NONE
    hi Todo         gui=bold guifg=#282c34 guibg=#e5c07b

    hi CursorLine   gui=NONE guibg=#2c313c
    hi CursorColumn gui=NONE guibg=#2c313c
    hi ColorColumn  gui=NONE guibg=#2c313c

    hi LineNr       gui=NONE guifg=#4b5263
    hi CursorLineNr gui=bold guifg=#61afef

    hi StatusLine   gui=NONE guifg=#abb2bf guibg=#2c313c
    hi StatusLineNC gui=NONE guifg=#5c6370 guibg=#2c313c

    hi VertSplit    gui=NONE guifg=#3e4452 guibg=NONE
    hi Visual       gui=NONE guibg=#3e4452

    hi Search       gui=NONE guifg=#282c34 guibg=#e5c07b
    hi IncSearch    gui=NONE guifg=#282c34 guibg=#d19a66

    hi Pmenu        gui=NONE guifg=#abb2bf guibg=#2c313c
    hi PmenuSel     gui=NONE guifg=#282c34 guibg=#61afef

    hi Error        gui=NONE guifg=#e06c75 guibg=NONE
    hi WarningMsg   gui=NONE guifg=#e5c07b guibg=NONE
endif
