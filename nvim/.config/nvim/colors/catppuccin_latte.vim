" ============================================================================
" Catppuccin Latte - vim colorscheme for Neovim
" Place this file at: ~/.config/nvim/colors/catppuccin-latte.vim
" Activate with:      :colorscheme catppuccin-latte
" (it will then show up in Telescope's <colorscheme> picker too)
" ============================================================================

hi clear
if exists('syntax_on')
  syntax reset
endif

set termguicolors
let g:colors_name = 'catppuccin-latte'

" ---------------------------------------------------------------------------
" Palette (Catppuccin Latte)
" ---------------------------------------------------------------------------
let s:rosewater = '#dc8a78'
let s:flamingo  = '#dd7878'
let s:pink      = '#ea76cb'
let s:mauve     = '#8839ef'
let s:red       = '#d20f39'
let s:maroon    = '#e64553'
let s:peach     = '#fe640b'
let s:yellow    = '#df8e1d'
let s:green     = '#40a02b'
let s:teal      = '#179299'
let s:sky       = '#04a5e5'
let s:sapphire  = '#209fb5'
let s:blue      = '#1e66f5'
let s:lavender  = '#7287fd'

let s:text      = '#4c4f69'
let s:subtext1  = '#5c5f77'
let s:subtext0  = '#6c6f85'
let s:overlay2  = '#7c7f93'
let s:overlay1  = '#8c8fa1'
let s:overlay0  = '#9ca0b0'
let s:surface2  = '#acb0be'
let s:surface1  = '#bcc0cc'
let s:surface0  = '#ccd0da'

let s:base      = '#eff1f5'
let s:mantle    = '#e6e9ef'
let s:crust     = '#dce0e8'

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
call s:hl('Normal',        s:text,     s:base,    '')
call s:hl('NormalFloat',   s:text,     s:mantle,  '')
call s:hl('NormalNC',      s:text,     s:base,    '')
call s:hl('FloatBorder',   s:blue,     s:mantle,  '')
call s:hl('Cursor',        s:base,     s:text,    '')
call s:hl('CursorLine',    s:none,     s:mantle,  '')
call s:hl('CursorLineNr',  s:peach,    s:mantle,  'bold')
call s:hl('LineNr',        s:overlay0, s:none,    '')
call s:hl('SignColumn',    s:none,     s:base,    '')
call s:hl('ColorColumn',   s:none,     s:mantle,  '')
call s:hl('VertSplit',     s:surface0, s:none,    '')
call s:hl('WinSeparator',  s:surface0, s:none,    '')
call s:hl('Visual',        s:none,     s:surface1,'')
call s:hl('VisualNOS',     s:none,     s:surface1,'')
call s:hl('Search',        s:base,     s:yellow,  '')
call s:hl('IncSearch',     s:base,     s:peach,   '')
call s:hl('CurSearch',     s:base,     s:peach,   '')
call s:hl('Substitute',    s:base,     s:red,     '')
call s:hl('MatchParen',    s:peach,    s:surface1,'bold')
call s:hl('Pmenu',         s:text,     s:surface0,'')
call s:hl('PmenuSel',      s:base,     s:blue,    'bold')
call s:hl('PmenuSbar',     s:none,     s:surface1,'')
call s:hl('PmenuThumb',    s:none,     s:overlay0,'')
call s:hl('StatusLine',    s:text,     s:mantle,  '')
call s:hl('StatusLineNC',  s:overlay0, s:mantle,  '')
call s:hl('TabLine',       s:overlay0, s:surface0,'')
call s:hl('TabLineFill',   s:overlay0, s:mantle,  '')
call s:hl('TabLineSel',    s:base,     s:blue,    'bold')
call s:hl('WildMenu',      s:base,     s:blue,    '')
call s:hl('Folded',        s:overlay1, s:surface0,'italic')
call s:hl('FoldColumn',    s:overlay0, s:base,    '')
call s:hl('Title',         s:blue,     s:none,    'bold')
call s:hl('Directory',     s:blue,     s:none,    '')
call s:hl('ErrorMsg',      s:red,      s:none,    'bold')
call s:hl('WarningMsg',    s:yellow,   s:none,    'bold')
call s:hl('MoreMsg',       s:green,    s:none,    '')
call s:hl('Question',      s:blue,     s:none,    '')
call s:hl('NonText',       s:surface1, s:none,    '')
call s:hl('Whitespace',    s:surface1, s:none,    '')
call s:hl('SpecialKey',    s:overlay0, s:none,    '')
call s:hl('EndOfBuffer',   s:surface1, s:none,    '')
call s:hl('Conceal',       s:overlay1, s:none,    '')
call s:hl('QuickFixLine',  s:none,     s:surface0,'')
call s:hl('SpellBad',      s:red,      s:none,    'undercurl')
call s:hl('SpellCap',      s:yellow,   s:none,    'undercurl')
call s:hl('SpellRare',     s:pink,     s:none,    'undercurl')
call s:hl('SpellLocal',    s:teal,     s:none,    'undercurl')

" Diff
call s:hl('DiffAdd',    s:green,  s:mantle, '')
call s:hl('DiffChange', s:yellow, s:mantle, '')
call s:hl('DiffDelete', s:red,    s:mantle, '')
call s:hl('DiffText',   s:blue,   s:mantle, 'bold')

" Diagnostics
call s:hl('DiagnosticError', s:red,    s:none, '')
call s:hl('DiagnosticWarn',  s:yellow, s:none, '')
call s:hl('DiagnosticInfo',  s:sky,    s:none, '')
call s:hl('DiagnosticHint',  s:teal,   s:none, '')
call s:hl('DiagnosticUnderlineError', s:red,    s:none, 'undercurl')
call s:hl('DiagnosticUnderlineWarn',  s:yellow, s:none, 'undercurl')
call s:hl('DiagnosticUnderlineInfo',  s:sky,    s:none, 'undercurl')
call s:hl('DiagnosticUnderlineHint',  s:teal,   s:none, 'undercurl')

" ---------------------------------------------------------------------------
" Syntax
" ---------------------------------------------------------------------------
call s:hl('Comment',        s:overlay1, s:none, 'italic')
call s:hl('Constant',       s:peach,    s:none, '')
call s:hl('String',         s:green,    s:none, '')
call s:hl('Character',      s:teal,     s:none, '')
call s:hl('Number',         s:peach,    s:none, '')
call s:hl('Boolean',        s:peach,    s:none, '')
call s:hl('Float',          s:peach,    s:none, '')
call s:hl('Identifier',     s:red,      s:none, '')
call s:hl('Function',       s:blue,     s:none, 'bold')
call s:hl('Statement',      s:mauve,    s:none, 'bold')
call s:hl('Conditional',    s:mauve,    s:none, '')
call s:hl('Repeat',         s:mauve,    s:none, '')
call s:hl('Label',          s:sapphire, s:none, '')
call s:hl('Operator',       s:sky,      s:none, '')
call s:hl('Keyword',        s:mauve,    s:none, '')
call s:hl('Exception',      s:mauve,    s:none, '')
call s:hl('PreProc',        s:pink,     s:none, '')
call s:hl('Include',        s:mauve,    s:none, '')
call s:hl('Define',         s:mauve,    s:none, '')
call s:hl('Macro',          s:pink,     s:none, '')
call s:hl('PreCondit',      s:pink,     s:none, '')
call s:hl('Type',           s:yellow,   s:none, '')
call s:hl('StorageClass',   s:yellow,   s:none, '')
call s:hl('Structure',      s:yellow,   s:none, '')
call s:hl('Typedef',        s:yellow,   s:none, '')
call s:hl('Special',        s:sapphire, s:none, '')
call s:hl('SpecialChar',    s:sapphire, s:none, '')
call s:hl('Tag',            s:mauve,    s:none, '')
call s:hl('Delimiter',      s:overlay2, s:none, '')
call s:hl('SpecialComment', s:overlay1, s:none, 'italic')
call s:hl('Debug',          s:red,      s:none, '')
call s:hl('Underlined',     s:blue,     s:none, 'underline')
call s:hl('Ignore',         s:overlay0, s:none, '')
call s:hl('Error',          s:red,      s:none, 'bold')
call s:hl('Todo',           s:base,     s:yellow,'bold')

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
call s:hl('TelescopeNormal',        s:text,     s:mantle, '')
call s:hl('TelescopeBorder',        s:blue,     s:mantle, '')
call s:hl('TelescopePromptNormal',  s:text,     s:surface0,'')
call s:hl('TelescopePromptBorder',  s:blue,     s:surface0,'')
call s:hl('TelescopePromptPrefix',  s:peach,    s:surface0,'')
call s:hl('TelescopePromptTitle',   s:base,     s:peach,  'bold')
call s:hl('TelescopePreviewTitle',  s:base,     s:green,  'bold')
call s:hl('TelescopeResultsTitle',  s:base,     s:blue,   'bold')
call s:hl('TelescopeSelection',     s:text,     s:surface0,'bold')
call s:hl('TelescopeSelectionCaret',s:peach,    s:surface0,'')
call s:hl('TelescopeMatching',      s:peach,    s:none,   'bold')
call s:hl('TelescopeMultiSelection',s:mauve,    s:none,   'bold')

" ---------------------------------------------------------------------------
" nvim-cmp
" ---------------------------------------------------------------------------
call s:hl('CmpItemAbbr',           s:text,     s:none, '')
call s:hl('CmpItemAbbrMatch',      s:blue,     s:none, 'bold')
call s:hl('CmpItemAbbrMatchFuzzy', s:blue,     s:none, 'bold')
call s:hl('CmpItemKind',           s:mauve,    s:none, '')
call s:hl('CmpItemMenu',           s:overlay1, s:none, 'italic')

" ---------------------------------------------------------------------------
" GitSigns
" ---------------------------------------------------------------------------
call s:hl('GitSignsAdd',    s:green,  s:none, '')
call s:hl('GitSignsChange', s:yellow, s:none, '')
call s:hl('GitSignsDelete', s:red,    s:none, '')

" cleanup helper function from global namespace
delfunction s:hl
