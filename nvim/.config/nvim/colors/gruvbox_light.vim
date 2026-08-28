" ============================================================================
" Gruvbox Light - vim colorscheme for Neovim
" Place this file at: ~/.config/nvim/colors/gruvbox-light.vim
" Activate with:      :colorscheme gruvbox-light
" (it will then show up in Telescope's <colorscheme> picker too)
" ============================================================================

hi clear
if exists('syntax_on')
  syntax reset
endif

set termguicolors
let g:colors_name = 'gruvbox-light'

" ---------------------------------------------------------------------------
" Palette (Gruvbox Light, "medium" contrast)
" ---------------------------------------------------------------------------
let s:bg0       = '#fbf1c7'
let s:bg0_hard  = '#f9f5d7'
let s:bg0_soft  = '#f2e5bc'
let s:bg1       = '#ebdbb2'
let s:bg2       = '#d5c4a1'
let s:bg3       = '#bdae93'
let s:bg4       = '#a89984'

let s:gray      = '#928374'

let s:fg0       = '#282828'
let s:fg1       = '#3c3836'
let s:fg2       = '#504945'
let s:fg3       = '#665c54'
let s:fg4       = '#7c6f64'

let s:red        = '#cc241d'
let s:red_dim    = '#9d0006'
let s:green      = '#98971a'
let s:green_dim  = '#79740e'
let s:yellow     = '#d79921'
let s:yellow_dim = '#b57614'
let s:blue       = '#458588'
let s:blue_dim   = '#076678'
let s:purple     = '#b16286'
let s:purple_dim = '#8f3f71'
let s:aqua       = '#689d6a'
let s:aqua_dim   = '#427b58'
let s:orange     = '#d65d0e'
let s:orange_dim = '#af3a03'

let s:none      = 'NONE'

" ---------------------------------------------------------------------------
" Helper to define highlight groups
" ---------------------------------------------------------------------------
function! s:hl(group, fg, bg, attr) abort
  let l:cmd = 'hi ' . a:group
  let l:cmd .= ' guifg=' . a:fg
  let l:cmd .= ' guibg=' . a:bg
  let l:cmd .= ' gui=' . (a:attr ==# '' ? 'NONE' : a:attr)
  let l:cmd .= ' cterm=' . (a:attr ==# '' ? 'NONE' : a:attr)
  execute l:cmd
endfunction

" ---------------------------------------------------------------------------
" Editor UI
" ---------------------------------------------------------------------------
call s:hl('Normal',        s:fg1,   s:bg0,      '')
call s:hl('NormalFloat',   s:fg1,   s:bg0_soft, '')
call s:hl('NormalNC',      s:fg1,   s:bg0,      '')
call s:hl('FloatBorder',   s:blue_dim, s:bg0_soft, '')
call s:hl('Cursor',        s:bg0,   s:fg1,      '')
call s:hl('CursorLine',    s:none,  s:bg1,      '')
call s:hl('CursorLineNr',  s:orange_dim, s:bg1, 'bold')
call s:hl('LineNr',        s:bg4,   s:none,     '')
call s:hl('SignColumn',    s:none,  s:bg0,      '')
call s:hl('ColorColumn',   s:none,  s:bg1,      '')
call s:hl('VertSplit',     s:bg2,   s:none,     '')
call s:hl('WinSeparator',  s:bg2,   s:none,     '')
call s:hl('Visual',        s:none,  s:bg2,      '')
call s:hl('VisualNOS',     s:none,  s:bg2,      '')
call s:hl('Search',        s:bg0,   s:yellow,   '')
call s:hl('IncSearch',     s:bg0,   s:orange,   '')
call s:hl('CurSearch',     s:bg0,   s:orange,   '')
call s:hl('Substitute',    s:bg0,   s:red,      '')
call s:hl('MatchParen',    s:orange_dim, s:bg2, 'bold')
call s:hl('Pmenu',         s:fg1,   s:bg1,      '')
call s:hl('PmenuSel',      s:bg0,   s:blue_dim, 'bold')
call s:hl('PmenuSbar',     s:none,  s:bg2,      '')
call s:hl('PmenuThumb',    s:none,  s:bg4,      '')
call s:hl('StatusLine',    s:fg1,   s:bg1,      '')
call s:hl('StatusLineNC',  s:bg4,   s:bg1,      '')
call s:hl('TabLine',       s:bg4,   s:bg1,      '')
call s:hl('TabLineFill',   s:bg4,   s:bg0_soft, '')
call s:hl('TabLineSel',    s:bg0,   s:blue_dim, 'bold')
call s:hl('WildMenu',      s:bg0,   s:blue_dim, '')
call s:hl('Folded',        s:fg4,   s:bg1,      'italic')
call s:hl('FoldColumn',    s:bg4,   s:bg0,      '')
call s:hl('Title',         s:blue_dim, s:none,  'bold')
call s:hl('Directory',     s:blue_dim, s:none,  '')
call s:hl('ErrorMsg',      s:red_dim,  s:none,  'bold')
call s:hl('WarningMsg',    s:yellow_dim, s:none,'bold')
call s:hl('MoreMsg',       s:green_dim,  s:none,'')
call s:hl('Question',      s:blue_dim, s:none,  '')
call s:hl('NonText',       s:bg2,   s:none,     '')
call s:hl('Whitespace',    s:bg2,   s:none,     '')
call s:hl('SpecialKey',    s:bg4,   s:none,     '')
call s:hl('EndOfBuffer',   s:bg2,   s:none,     '')
call s:hl('Conceal',       s:fg4,   s:none,     '')
call s:hl('QuickFixLine',  s:none,  s:bg1,      '')
call s:hl('SpellBad',      s:red_dim,    s:none, 'undercurl')
call s:hl('SpellCap',      s:yellow_dim, s:none, 'undercurl')
call s:hl('SpellRare',     s:purple_dim, s:none, 'undercurl')
call s:hl('SpellLocal',    s:aqua_dim,   s:none, 'undercurl')

" Diff
call s:hl('DiffAdd',    s:green_dim,  s:bg1, '')
call s:hl('DiffChange', s:yellow_dim, s:bg1, '')
call s:hl('DiffDelete', s:red_dim,    s:bg1, '')
call s:hl('DiffText',   s:blue_dim,   s:bg1, 'bold')

" Diagnostics
call s:hl('DiagnosticError', s:red_dim,    s:none, '')
call s:hl('DiagnosticWarn',  s:yellow_dim, s:none, '')
call s:hl('DiagnosticInfo',  s:blue_dim,   s:none, '')
call s:hl('DiagnosticHint',  s:aqua_dim,   s:none, '')
call s:hl('DiagnosticUnderlineError', s:red_dim,    s:none, 'undercurl')
call s:hl('DiagnosticUnderlineWarn',  s:yellow_dim, s:none, 'undercurl')
call s:hl('DiagnosticUnderlineInfo',  s:blue_dim,   s:none, 'undercurl')
call s:hl('DiagnosticUnderlineHint',  s:aqua_dim,   s:none, 'undercurl')

" ---------------------------------------------------------------------------
" Syntax
" ---------------------------------------------------------------------------
call s:hl('Comment',        s:gray,     s:none, 'italic')
call s:hl('Constant',       s:purple,   s:none, '')
call s:hl('String',         s:green_dim,s:none, '')
call s:hl('Character',      s:green_dim,s:none, '')
call s:hl('Number',         s:purple,   s:none, '')
call s:hl('Boolean',        s:purple,   s:none, '')
call s:hl('Float',          s:purple,   s:none, '')
call s:hl('Identifier',     s:blue_dim, s:none, '')
call s:hl('Function',       s:green_dim,s:none, 'bold')
call s:hl('Statement',      s:red_dim,  s:none, 'bold')
call s:hl('Conditional',    s:red_dim,  s:none, '')
call s:hl('Repeat',         s:red_dim,  s:none, '')
call s:hl('Label',          s:red_dim,  s:none, '')
call s:hl('Operator',       s:fg1,      s:none, '')
call s:hl('Keyword',        s:red_dim,  s:none, '')
call s:hl('Exception',      s:red_dim,  s:none, '')
call s:hl('PreProc',        s:aqua_dim, s:none, '')
call s:hl('Include',        s:aqua_dim, s:none, '')
call s:hl('Define',         s:aqua_dim, s:none, '')
call s:hl('Macro',          s:aqua_dim, s:none, '')
call s:hl('PreCondit',      s:aqua_dim, s:none, '')
call s:hl('Type',           s:yellow_dim,s:none,'')
call s:hl('StorageClass',   s:orange_dim,s:none,'')
call s:hl('Structure',      s:aqua_dim, s:none, '')
call s:hl('Typedef',        s:yellow_dim,s:none,'')
call s:hl('Special',        s:orange_dim,s:none,'')
call s:hl('SpecialChar',    s:orange_dim,s:none,'')
call s:hl('Tag',            s:red_dim,  s:none, '')
call s:hl('Delimiter',      s:fg2,      s:none, '')
call s:hl('SpecialComment', s:gray,     s:none, 'italic')
call s:hl('Debug',          s:red_dim,  s:none, '')
call s:hl('Underlined',     s:blue_dim, s:none, 'underline')
call s:hl('Ignore',         s:bg4,      s:none, '')
call s:hl('Error',          s:red_dim,  s:none, 'bold')
call s:hl('Todo',           s:bg0,      s:yellow, 'bold')

" ---------------------------------------------------------------------------
" Treesitter (@ groups) — link to core groups so most langs look right
" ---------------------------------------------------------------------------
hi link @variable            Identifier
hi link @variable.builtin    Constant
hi link @variable.parameter  Identifier
hi link @constant            Constant
hi link @constant.builtin    Constant
hi link @string              String
hi link @string.escape       SpecialChar
hi link @character           Character
hi link @number              Number
hi link @boolean             Boolean
hi link @float               Float
hi link @function            Function
hi link @function.builtin    Function
hi link @function.call       Function
hi link @method              Function
hi link @method.call         Function
hi link @constructor         Type
hi link @keyword             Keyword
hi link @keyword.function    Keyword
hi link @keyword.return      Keyword
hi link @conditional         Conditional
hi link @repeat              Repeat
hi link @label               Label
hi link @operator            Operator
hi link @exception           Exception
hi link @type                Type
hi link @type.builtin        Type
hi link @field               Identifier
hi link @property            Identifier
hi link @punctuation.bracket Delimiter
hi link @punctuation.delimiter Delimiter
hi link @comment              Comment
hi link @tag                  Tag
hi link @tag.attribute        Type
hi link @tag.delimiter        Delimiter

" ---------------------------------------------------------------------------
" LSP semantic tokens
" ---------------------------------------------------------------------------
hi link @lsp.type.class        Type
hi link @lsp.type.function     Function
hi link @lsp.type.method       Function
hi link @lsp.type.variable     Identifier
hi link @lsp.type.parameter    Identifier
hi link @lsp.type.property     Identifier
hi link @lsp.type.interface    Type
hi link @lsp.type.enum         Type
hi link @lsp.type.keyword      Keyword

" ---------------------------------------------------------------------------
" Telescope
" ---------------------------------------------------------------------------
call s:hl('TelescopeNormal',        s:fg1,   s:bg0_soft, '')
call s:hl('TelescopeBorder',        s:blue_dim, s:bg0_soft, '')
call s:hl('TelescopePromptNormal',  s:fg1,   s:bg1, '')
call s:hl('TelescopePromptBorder',  s:blue_dim, s:bg1, '')
call s:hl('TelescopePromptPrefix',  s:orange_dim, s:bg1, '')
call s:hl('TelescopePromptTitle',   s:bg0,   s:orange_dim, 'bold')
call s:hl('TelescopePreviewTitle',  s:bg0,   s:green_dim,  'bold')
call s:hl('TelescopeResultsTitle',  s:bg0,   s:blue_dim,   'bold')
call s:hl('TelescopeSelection',     s:fg1,   s:bg2, 'bold')
call s:hl('TelescopeSelectionCaret',s:orange_dim, s:bg2, '')
call s:hl('TelescopeMatching',      s:orange_dim, s:none, 'bold')
call s:hl('TelescopeMultiSelection',s:purple_dim, s:none, 'bold')

" ---------------------------------------------------------------------------
" nvim-cmp
" ---------------------------------------------------------------------------
call s:hl('CmpItemAbbr',           s:fg1,      s:none, '')
call s:hl('CmpItemAbbrMatch',      s:blue_dim, s:none, 'bold')
call s:hl('CmpItemAbbrMatchFuzzy', s:blue_dim, s:none, 'bold')
call s:hl('CmpItemKind',           s:purple_dim,s:none, '')
call s:hl('CmpItemMenu',           s:gray,     s:none, 'italic')

" ---------------------------------------------------------------------------
" GitSigns
" ---------------------------------------------------------------------------
call s:hl('GitSignsAdd',    s:green_dim,  s:none, '')
call s:hl('GitSignsChange', s:yellow_dim, s:none, '')
call s:hl('GitSignsDelete', s:red_dim,    s:none, '')

" cleanup helper function from global namespace
delfunction s:hl
