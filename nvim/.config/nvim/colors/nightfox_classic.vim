hi clear
syntax reset
let g:colors_name = "nightfox_classic"

if &background == "dark"
    hi Normal       gui=NONE guifg=#cdcecf guibg=#192330
    hi Comment      gui=italic guifg=#738091 guibg=NONE

    hi Constant     gui=NONE guifg=#f4a261 guibg=NONE
    hi String       gui=NONE guifg=#8ebaa4 guibg=NONE
    hi Character    gui=NONE guifg=#8ebaa4 guibg=NONE
    hi Number       gui=NONE guifg=#f4a261 guibg=NONE
    hi Boolean      gui=NONE guifg=#f4a261 guibg=NONE
    hi Float        gui=NONE guifg=#f4a261 guibg=NONE

    hi Identifier   gui=NONE guifg=#cdcecf guibg=NONE
    hi Function     gui=NONE guifg=#719cd6 guibg=NONE

    hi Statement    gui=NONE guifg=#bb9af7 guibg=NONE
    hi Conditional  gui=NONE guifg=#bb9af7 guibg=NONE
    hi Repeat       gui=NONE guifg=#bb9af7 guibg=NONE
    hi Label        gui=NONE guifg=#bb9af7 guibg=NONE
    hi Operator     gui=NONE guifg=#86abdc guibg=NONE
    hi Keyword      gui=NONE guifg=#bb9af7 guibg=NONE
    hi Exception    gui=NONE guifg=#c94f6d guibg=NONE

    hi PreProc      gui=NONE guifg=#63cdcf guibg=NONE
    hi Include      gui=NONE guifg=#63cdcf guibg=NONE
    hi Define       gui=NONE guifg=#63cdcf guibg=NONE
    hi Macro        gui=NONE guifg=#63cdcf guibg=NONE

    hi Type         gui=NONE guifg=#63cdcf guibg=NONE
    hi StorageClass gui=NONE guifg=#dbc074 guibg=NONE
    hi Structure    gui=NONE guifg=#63cdcf guibg=NONE
    hi Typedef      gui=NONE guifg=#63cdcf guibg=NONE

    hi Special      gui=NONE guifg=#9d79d6 guibg=NONE
    hi Underlined   gui=underline guifg=#719cd6 guibg=NONE
    hi Todo         gui=bold guifg=#192330 guibg=#dbc074

    hi CursorLine   gui=NONE guibg=#212e3f
    hi CursorColumn gui=NONE guibg=#212e3f
    hi ColorColumn  gui=NONE guibg=#212e3f

    hi LineNr       gui=NONE guifg=#526175
    hi CursorLineNr gui=bold guifg=#719cd6

    hi StatusLine   gui=NONE guifg=#cdcecf guibg=#212e3f
    hi StatusLineNC gui=NONE guifg=#738091 guibg=#212e3f

    hi VertSplit    gui=NONE guifg=#2f3f54 guibg=NONE
    hi Visual       gui=NONE guibg=#2f3f54

    hi Search       gui=NONE guifg=#192330 guibg=#dbc074
    hi IncSearch    gui=NONE guifg=#192330 guibg=#f4a261

    hi Pmenu        gui=NONE guifg=#cdcecf guibg=#212e3f
    hi PmenuSel     gui=NONE guifg=#192330 guibg=#719cd6

    hi Error        gui=NONE guifg=#c94f6d guibg=NONE
    hi WarningMsg   gui=NONE guifg=#dbc074 guibg=NONE
endif
