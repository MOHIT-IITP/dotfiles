hi clear
syntax reset
let g:colors_name = "rose_pine_classic"

if &background == "dark"
    hi Normal       gui=NONE guifg=#e0def4 guibg=#191724
    hi Comment      gui=italic guifg=#6e6a86 guibg=NONE

    hi Constant     gui=NONE guifg=#ebbcba guibg=NONE
    hi String       gui=NONE guifg=#9ccfd8 guibg=NONE
    hi Character    gui=NONE guifg=#9ccfd8 guibg=NONE
    hi Number       gui=NONE guifg=#ebbcba guibg=NONE
    hi Boolean      gui=NONE guifg=#ebbcba guibg=NONE
    hi Float        gui=NONE guifg=#ebbcba guibg=NONE

    hi Identifier   gui=NONE guifg=#e0def4 guibg=NONE
    hi Function     gui=NONE guifg=#c4a7e7 guibg=NONE

    hi Statement    gui=NONE guifg=#eb6f92 guibg=NONE
    hi Conditional  gui=NONE guifg=#eb6f92 guibg=NONE
    hi Repeat       gui=NONE guifg=#eb6f92 guibg=NONE
    hi Label        gui=NONE guifg=#eb6f92 guibg=NONE
    hi Operator     gui=NONE guifg=#f6c177 guibg=NONE
    hi Keyword      gui=NONE guifg=#eb6f92 guibg=NONE
    hi Exception    gui=NONE guifg=#eb6f92 guibg=NONE

    hi PreProc      gui=NONE guifg=#31748f guibg=NONE
    hi Include      gui=NONE guifg=#31748f guibg=NONE
    hi Define       gui=NONE guifg=#31748f guibg=NONE
    hi Macro        gui=NONE guifg=#31748f guibg=NONE

    hi Type         gui=NONE guifg=#31748f guibg=NONE
    hi StorageClass gui=NONE guifg=#f6c177 guibg=NONE
    hi Structure    gui=NONE guifg=#31748f guibg=NONE
    hi Typedef      gui=NONE guifg=#31748f guibg=NONE

    hi Special      gui=NONE guifg=#c4a7e7 guibg=NONE
    hi Underlined   gui=underline guifg=#9ccfd8 guibg=NONE
    hi Todo         gui=bold guifg=#191724 guibg=#f6c177

    hi CursorLine   gui=NONE guibg=#26233a
    hi CursorColumn gui=NONE guibg=#26233a
    hi ColorColumn  gui=NONE guibg=#26233a

    hi LineNr       gui=NONE guifg=#524f67
    hi CursorLineNr gui=bold guifg=#c4a7e7

    hi StatusLine   gui=NONE guifg=#e0def4 guibg=#26233a
    hi StatusLineNC gui=NONE guifg=#6e6a86 guibg=#26233a

    hi VertSplit    gui=NONE guifg=#393552 guibg=NONE
    hi Visual       gui=NONE guibg=#393552

    hi Search       gui=NONE guifg=#191724 guibg=#f6c177
    hi IncSearch    gui=NONE guifg=#191724 guibg=#ebbcba

    hi Pmenu        gui=NONE guifg=#e0def4 guibg=#26233a
    hi PmenuSel     gui=NONE guifg=#191724 guibg=#c4a7e7

    hi Error        gui=NONE guifg=#eb6f92 guibg=NONE
    hi WarningMsg   gui=NONE guifg=#f6c177 guibg=NONE
endif
