local tc = require 'themecolor'

-- taken from https://github.com/norcalli/nvim-base16.lua/blob/master/lua/base16.lua
local function highlight(group, guifg, guibg, ctermfg, ctermbg, attr, guisp, force)
	local gfg = guifg and "guifg=#"..guifg or 'guifg=none'
	local gbg = guibg and "guibg=#"..guibg or 'guibg=none'
	local ctfg = ctermfg and "ctermfg="..ctermfg or 'ctermfg=none'
	local ctbg = ctermbg and "ctermbg="..ctermbg or 'ctermbg=none'
	local attrs = attr and 'gui=' .. attr .. ' cterm=' .. attr or 'gui=none cterm=none'
	local gsp = guisp and "guisp=#"..guisp or 'guisp=none'

	vim.api.nvim_command('hi' .. (force and '! ' or ' ')..table.concat({group, gfg, gbg, ctfg, ctbg, gsp, attrs}, ' '))
end

local highlights = {
	-- Basic Syntax Colors
	NonText = {gfg = tc.gui12, ctfg = 12},
	SpellBad = {gfg = tc.gui1, ctfg = 1, attr = 'underlineitalic'},
	SpellCap = {gfg = tc.gui4, ctfg = 4, attr = 'underlineitalic'},
	SpellLocal = {gfg = tc.gui4, ctfg = 4, attr = 'italic'},
	SpellRare = {gfg = tc.gui14, ctfg = 14, attr = 'italic'},
	MatchParen = {gbg = tc.gui9, ctbg = 8},
	Constant = {gfg = tc.gui2, ctfg = 2},
	Special = {gfg = tc.gui5, ctfg = 5},
	Identifier = {gfg = tc.gui4, ctfg = 4},
	Statement = {gfg = tc.gui3, ctfg = 3},
	PreProc = {gfg = tc.gui5, ctfg = 5},
	Type = {gfg = tc.gui2, ctfg = 2},
	Underlined = {gfg = tc.gui6, ctfg = 6, attr = 'underline'},
	Ignore = {gfg = tc.fg, ctfg = 15},
	Error = {gfg = tc.gui9, ctfg = 9, attr = 'underlineitalic'},
	Todo = {gfg = tc.bg, gbg = tc.gui8, ctfg = 0, ctbg = 8, attr = 'underline'},
	Comment = {gfg = tc.gui8, ctfg = 8, attr = 'italic'},

	-- Treesitter :despair:
	TSAttribute = {gfg = tc.gui3, attr = 'bold'},
	TSAnnotation = {gfg = tc.gui3, attr = 'bold'}, -- basically decorators? ie @deprecated
	TSBoolean = {gfg = tc.gui1},
	TSCharacter = {gfg = tc.gui2}, -- a character lol
	TSComment = {gfg = tc.gui8, attr = 'italic'},
	TSConditional = {gfg = tc.gui3}, -- if, else
	TSConstant = {gfg = tc.gui1}, -- const variables; those in all caps
	TSConstBuiltin = {gfg = tc.gui3, attr = 'italic'}, -- already provided global consts, nil as example
	TSConstMacro = {gfg = tc.gui1, attr = 'italic'}, -- consts that are macros, like NULL in c
	TSConstructor = {gfg = tc.gui1},
	TSError = {gfg = tc.gui1, attr = 'italic'}, -- lsp errors
--	TSException = {}, -- TODO
	TSField = {gfg = tc.fg}, -- lua: tbl = {FIELD = 'thing'}, highlights FIELD
	TSFloat = {gfg = tc.gui1, ctfg = 5},
	TSFunction = {gfg = tc.gui4}, -- function declaration and use
	TSFuncBuiltin = {gfg = tc.gui6, attr = 'italic'},
	TSFuncMacro = {gfg = tc.gui12, attr = 'italic'}, -- macro functions and decls, println! in rust
	TSInclude = {gfg = tc.gui12, attr = 'italic'}, -- require, #include
	TSKeyword = {gfg = tc.gui5}, -- normal keywrds
	TSKeywordFunction = {gfg = tc.gui12}, -- keyword to define function (function in lua)
	TSKeywordOperator = {gfg = tc.gui3, attr = 'italic'}, -- word operators (or/and)
	TSLabel = {gfg = tc.gui9}, -- ::label:: in lua
	TSMethod = {gfg = tc.gui4, ctfg = 4}, -- function calls
--	TSNamespace = {}, -- TODO
	TSNumber = {gfg = tc.gui1, ctfg = 1},
	TSOperator = {gfg = tc.gui3},
	TSParameter = {gfg = tc.gui3, attr = 'italic'}, -- function params
-- TSParameterReference = {}, -- TODO
	TSProperty = {gfg = tc.gui4}, -- access properties: thing.Property
	TSPunctDelimiter = {gfg = tc.fg, ctfg = 7}, -- dot/colon accessors to properties?
	TSPunctBracket = {gfg = tc.fg},
	TSPunctSpecial = {gfg = tc.fg},
	TSRepeat = {gfg = tc.gui9, attr = 'italic'}, -- keywords for loops, while, for, do in lua
	TSString = {gfg = tc.gui2, ctfg = 2},
	TSStringRegex = {gfg = tc.gui12, attr = 'italic'},
	TSStringEscape = {gfg = tc.gui1, ctfg = 1},
	TSTag = {gfg = tc.gui3}, -- html tag names
	TSTagDelimiter = {gfg = tc.gui12}, -- < /> in html
	TSURI = {gfg = tc.gui6, attr = 'underline'}, -- email/url (should be)
	TSWarning = {gfg = tc.gui3},
	TSDanger = {gfg = tc.gui1, attr = 'bold'},
	TSType = {gfg = tc.gui2, ctfg = 2}, -- custom types
	TSTypeBuiltin = {gfg = tc.gui2, ctfg = 2, attr = 'italic'}, -- default types
	TSVariableBuiltin = {gfg = tc.gui12}, -- builtin vars

	-- Editor Elements
	Normal = {gbg = tc.bg},
	ErrorMsg = {gfg = tc.gui1, ctfg = 1, attr = 'underlineitalic'},
	CursorColumn = {gbg = tc.gui8, ctbg = 8},
	CursorLine = {attr = 'bold'},
	CursorLineNr = {gfg = tc.fgli, ctfg = 15},
	LineNr = {gfg = tc.gui8, ctfg = 11},
	MoreMsg = {gfg = tc.gui6, ctfg = 6},
	ModeMsg = {gfg = tc.gui5, ctfg = 5, attr = 'bold'},
	Question = {gfg = tc.gui2, ctfg = 2},
	WarningMsg = {gfg = tc.gui3, ctfg = 3, attr = 'underlineitalic'},
	Title = {gfg = tc.gui5, ctfg = 5},
	Conceal = {gfg = tc.bg, gbg = tc.bg, ctbg = 7, ctfg = 7},
	Search = {gbg = tc.bgvli, ctbg = 11},
	IncSearch = {gbg = tc.bgvli, ctbg = 8},
	PmenuSbar = {gbg = tc.gui8, ctbg = 8},
	PmenuThumb = {gbg = tc.bg, ctbg = 0},
	WildMenu = {gbg = tc.bgvli, ctbg = 11},
	Tabline = {gfg = tc.bg, gbg = tc.fg, ctfg = 0, ctbg = 7, attr = 'underline'},
	TablineSel = {attr = 'bold'},
	TablineFill = {attr = 'reverse'},
	Directory = {gfg = tc.gui4, ctfg = 4},
	SpecialKey = {gfg = tc.gui4, ctfg = 4},
	TermCursor = {attr = 'reverse'},
	EndOfBuffer = {gfg = tc.bg, gbg = tc.bg, ctfg = 0, ctbg = 0},
	Visual = {gbg = tc.bgvli},
	ColorColumn = {gfg = tc.fg, gbg = tc.gui8, ctfg = 7, ctbg = 8},
	Folded = {gfg = tc.fg, gbg = tc.gui8, ctfg = 7, ctbg = 8},
	FoldColumn = {gfg = tc.fg, gbg = tc.gui8, ctfg = 7, ctbg = 8},
	Pmenu = {gfg = tc.fgli, gbg = tc.gui8, ctfg = 15, ctbg = 8},
	PmenuSel = {gfg = tc.gui8, gbg = tc.fgli, ctfg = 8, ctbg = 15},
	StatusLine = {gfg = tc.bg, gbg = tc.bgli, ctfg = 15, ctbg = 8, attr = 'bold'},
	StatusLineNC = {gfg = tc.bg, gbg = tc.bgli, ctfg = 0, ctbg = 0, force = true},
	SignColumn = {},
	VertSplit = {gfg = tc.bgvli, gbg = tc.bg, ctfg = 0, ctbg = 0},

	-- Buffer Line
	BufferCurrent = {gbg = tc.bg, gfg = tc.fgli, attr = 'italic'},
	BufferCurrentMod = {attr = 'bolditalic'}, -- current modified
	BufferCurrentSign = {gbg = tc.bg, gfg = tc.bg}, -- seems to be some line near the buffer tab
	BufferInactive = {gbg = tc.bgli, gfg = tc.gui8},
	BufferInactiveMod = {gbg = tc.bgli, gfg = tc.gui3}, -- inactive modified (text)
	BufferInactiveSign = {gbg = tc.bgli, gfg = tc.bgli},
	BufferTabpageFill = {gbg = tc.bgli, gfg = tc.bgli}, -- rest of the bufferline
	BufferVisibleSign = {gfg = tc.bgvli, gbg = tc.bg},

	-- Dev Icons
	DevIconLua = {gfg = tc.gui4},
	DevIconGo = {gfg = tc.gui6},

	-- NvimTree
	NvimTreeEndOfBuffer = {gfg = tc.bg, gbg = tc.bg, ctfg = 0, ctbg = 0},
	NvimTreeVertSplit = {gfg = tc.bg, gbg = tc.bg, ctfg = 0, ctbg = 0},
	NvimTreeNormal = {gfg = tc.fgli, gbg = tc.bg, ctfg = 7, ctbg = 0},
	NvimTreeRootFolder = {},
	NvimTreeGitDirty = {gfg = tc.gui4, ctfg = 4},
	NvimTreeGitNew = {gfg = tc.gui2, ctfg = 2, attr = 'italic'},
	NvimTreeGitRenamed = {gfg = tc.gui6, ctfg = 6, attr = 'italic'},
	NvimTreeGitStaged = {gfg = tc.gui2, ctfg = 2},
	NvimTreeStatusLine = {gbg = tc.bgli, gfg = tc.bgli, force = true},
	NvimTreeExecFile = {gfg = tc.gui2, ctfg = 2, attr = 'underline'},
	NvimTreeGitDeleted = {gfg = tc.gui1, ctfg = 1, attr = 'bold'},

	-- GitSigns.nvim
	GitSignsAdd = {gfg = tc.gui2, ctfg = 2},
	GitSignsDelete = {gfg = tc.gui1, ctfg = 1},
	GitSignsChange = {gfg = tc.gui4, ctfg = 4},

	-- Scrollview
	ScrollView = {gbg = tc.gui8, ctbg = 8}
}

for group, styles in pairs(highlights) do
    highlight(group, styles.gfg, styles.gbg, styles.ctfg, styles.ctbg, styles.attr, nil, styles.force)
end
