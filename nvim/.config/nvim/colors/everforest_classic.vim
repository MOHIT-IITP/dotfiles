hi clear
syntax reset
let g:colors_name = "everforest_classic"

if &background == "dark"
    hi Normal       gui=NONE guifg=#d3c6aa guibg=#2d353b
    hi Comment      gui=italic guifg=#859289 guibg=NONE

    hi Constant     gui=NONE guifg=#e69875 guibg=NONE
    hi String       gui=NONE guifg=#a7c080 guibg=NONE
    hi Character    gui=NONE guifg=#a7c080 guibg=NONE
    hi Number       gui=NONE guifg=#e69875 guibg=NONE
    hi Boolean      gui=NONE guifg=#e69875 guibg=NONE
    hi Float        gui=NONE guifg=#e69875 guibg=NONE

    hi Identifier   gui=NONE guifg=#d3c6aa guibg=NONE
    hi Function     gui=NONE guifg=#7fbbb3 guibg=NONE

    hi Statement    gui=NONE guifg=#e67e80 guibg=NONE
    hi Conditional  gui=NONE guifg=#e67e80 guibg=NONE
    hi Repeat       gui=NONE guifg=#e67e80 guibg=NONE
    hi Label        gui=NONE guifg=#e67e80 guibg=NONE
    hi Operator     gui=NONE guifg=#dbbc7f guibg=NONE
    hi Keyword      gui=NONE guifg=#e67e80 guibg=NONE
    hi Exception    gui=NONE guifg=#e67e80 guibg=NONE

    hi PreProc      gui=NONE guifg=#83c092 guibg=NONE
    hi Include      gui=NONE guifg=#83c092 guibg=NONE
    hi Define       gui=NONE guifg=#83c092 guibg=NONE
    hi Macro        gui=NONE guifg=#83c092 guibg=NONE

    hi Type         gui=NONE guifg=#83c092 guibg=NONE
    hi StorageClass gui=NONE guifg=#dbbc7f guibg=NONE
    hi Structure    gui=NONE guifg=#83c092 guibg=NONE
    hi Typedef      gui=NONE guifg=#83c092 guibg=NONE

    hi Special      gui=NONE guifg=#7fbbb3 guibg=NONE
    hi Underlined   gui=underline guifg=#7fbbb3 guibg=NONE
    hi Todo         gui=bold guifg=#2d353b guibg=#dbbc7f

    hi CursorLine   gui=NONE guibg=#343f44
    hi CursorColumn gui=NONE guibg=#343f44
    hi ColorColumn  gui=NONE guibg=#343f44

    hi LineNr       gui=NONE guifg=#4f585e
    hi CursorLineNr gui=bold guifg=#a7c080

    hi StatusLine   gui=NONE guifg=#d3c6aa guibg=#343f44
    hi StatusLineNC gui=NONE guifg=#859289 guibg=#343f44

    hi VertSplit    gui=NONE guifg=#475258 guibg=NONE
    hi Visual       gui=NONE guibg=#475258

    hi Search       gui=NONE guifg=#2d353b guibg=#dbbc7f
    hi IncSearch    gui=NONE guifg=#2d353b guibg=#e69875

    hi Pmenu        gui=NONE guifg=#d3c6aa guibg=#343f44
    hi PmenuSel     gui=NONE guifg=#2d353b guibg=#7fbbb3

    hi Error        gui=NONE guifg=#e67e80 guibg=NONE
    hi WarningMsg   gui=NONE guifg=#dbbc7f guibg=NONE
endif
