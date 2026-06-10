hi clear
syntax reset
let g:colors_name = "nordic_classic"

if &background == "dark"
    hi Normal       gui=NONE guifg=#bbc3d4 guibg=#242933
    hi Comment      gui=italic guifg=#616e88 guibg=NONE

    hi Constant     gui=NONE guifg=#d08770 guibg=NONE
    hi String       gui=NONE guifg=#a3be8c guibg=NONE
    hi Character    gui=NONE guifg=#a3be8c guibg=NONE
    hi Number       gui=NONE guifg=#d08770 guibg=NONE
    hi Boolean      gui=NONE guifg=#d08770 guibg=NONE
    hi Float        gui=NONE guifg=#d08770 guibg=NONE

    hi Identifier   gui=NONE guifg=#bbc3d4 guibg=NONE
    hi Function     gui=NONE guifg=#81a1c1 guibg=NONE

    hi Statement    gui=NONE guifg=#b48ead guibg=NONE
    hi Conditional  gui=NONE guifg=#b48ead guibg=NONE
    hi Repeat       gui=NONE guifg=#b48ead guibg=NONE
    hi Label        gui=NONE guifg=#b48ead guibg=NONE
    hi Operator     gui=NONE guifg=#88c0d0 guibg=NONE
    hi Keyword      gui=NONE guifg=#b48ead guibg=NONE
    hi Exception    gui=NONE guifg=#bf616a guibg=NONE

    hi PreProc      gui=NONE guifg=#8fbcbb guibg=NONE
    hi Include      gui=NONE guifg=#8fbcbb guibg=NONE
    hi Define       gui=NONE guifg=#8fbcbb guibg=NONE
    hi Macro        gui=NONE guifg=#8fbcbb guibg=NONE

    hi Type         gui=NONE guifg=#8fbcbb guibg=NONE
    hi StorageClass gui=NONE guifg=#ebcb8b guibg=NONE
    hi Structure    gui=NONE guifg=#8fbcbb guibg=NONE
    hi Typedef      gui=NONE guifg=#8fbcbb guibg=NONE

    hi Special      gui=NONE guifg=#81a1c1 guibg=NONE
    hi Underlined   gui=underline guifg=#81a1c1 guibg=NONE
    hi Todo         gui=bold guifg=#242933 guibg=#ebcb8b

    hi CursorLine   gui=NONE guibg=#2e3440
    hi CursorColumn gui=NONE guibg=#2e3440
    hi ColorColumn  gui=NONE guibg=#2e3440

    hi LineNr       gui=NONE guifg=#4c566a
    hi CursorLineNr gui=bold guifg=#81a1c1

    hi StatusLine   gui=NONE guifg=#bbc3d4 guibg=#2e3440
    hi StatusLineNC gui=NONE guifg=#616e88 guibg=#2e3440

    hi VertSplit    gui=NONE guifg=#434c5e guibg=NONE
    hi Visual       gui=NONE guibg=#434c5e

    hi Search       gui=NONE guifg=#242933 guibg=#ebcb8b
    hi IncSearch    gui=NONE guifg=#242933 guibg=#d08770

    hi Pmenu        gui=NONE guifg=#bbc3d4 guibg=#2e3440
    hi PmenuSel     gui=NONE guifg=#242933 guibg=#81a1c1

    hi Error        gui=NONE guifg=#bf616a guibg=NONE
    hi WarningMsg   gui=NONE guifg=#ebcb8b guibg=NONE
endif
