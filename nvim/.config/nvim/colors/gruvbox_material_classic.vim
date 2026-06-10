hi clear
syntax reset
let g:colors_name = "gruvbox_material_classic"

if &background == "dark"
    hi Normal       gui=NONE guifg=#d4be98 guibg=#282828
    hi Comment      gui=italic guifg=#928374 guibg=NONE

    hi Constant     gui=NONE guifg=#d3869b guibg=NONE
    hi String       gui=NONE guifg=#a9b665 guibg=NONE
    hi Character    gui=NONE guifg=#a9b665 guibg=NONE
    hi Number       gui=NONE guifg=#d3869b guibg=NONE
    hi Boolean      gui=NONE guifg=#d3869b guibg=NONE
    hi Float        gui=NONE guifg=#d3869b guibg=NONE

    hi Identifier   gui=NONE guifg=#d4be98 guibg=NONE
    hi Function     gui=NONE guifg=#7daea3 guibg=NONE

    hi Statement    gui=NONE guifg=#ea6962 guibg=NONE
    hi Conditional  gui=NONE guifg=#ea6962 guibg=NONE
    hi Repeat       gui=NONE guifg=#ea6962 guibg=NONE
    hi Label        gui=NONE guifg=#ea6962 guibg=NONE
    hi Operator     gui=NONE guifg=#e78a4e guibg=NONE
    hi Keyword      gui=NONE guifg=#ea6962 guibg=NONE
    hi Exception    gui=NONE guifg=#ea6962 guibg=NONE

    hi PreProc      gui=NONE guifg=#89b482 guibg=NONE
    hi Include      gui=NONE guifg=#89b482 guibg=NONE
    hi Define       gui=NONE guifg=#89b482 guibg=NONE
    hi Macro        gui=NONE guifg=#89b482 guibg=NONE

    hi Type         gui=NONE guifg=#89b482 guibg=NONE
    hi StorageClass gui=NONE guifg=#e78a4e guibg=NONE
    hi Structure    gui=NONE guifg=#89b482 guibg=NONE
    hi Typedef      gui=NONE guifg=#89b482 guibg=NONE

    hi Special      gui=NONE guifg=#7daea3 guibg=NONE
    hi Underlined   gui=underline guifg=#7daea3 guibg=NONE
    hi Todo         gui=bold guifg=#282828 guibg=#d8a657

    hi CursorLine   gui=NONE guibg=#32302f
    hi CursorColumn gui=NONE guibg=#32302f
    hi ColorColumn  gui=NONE guibg=#32302f

    hi LineNr       gui=NONE guifg=#665c54
    hi CursorLineNr gui=bold guifg=#d8a657

    hi StatusLine   gui=NONE guifg=#d4be98 guibg=#3c3836
    hi StatusLineNC gui=NONE guifg=#928374 guibg=#3c3836

    hi VertSplit    gui=NONE guifg=#504945 guibg=NONE
    hi Visual       gui=NONE guibg=#504945

    hi Search       gui=NONE guifg=#282828 guibg=#d8a657
    hi IncSearch    gui=NONE guifg=#282828 guibg=#e78a4e

    hi Pmenu        gui=NONE guifg=#d4be98 guibg=#3c3836
    hi PmenuSel     gui=NONE guifg=#282828 guibg=#7daea3

    hi Error        gui=NONE guifg=#ea6962 guibg=NONE
    hi WarningMsg   gui=NONE guifg=#d8a657 guibg=NONE
endif
