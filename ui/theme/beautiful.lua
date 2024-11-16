local beautiful = require 'beautiful'
local settings = require 'sys.settings'
local palettes = require 'ui.theme.palettes'

local themeSettings = settings.getConfig 'theme'
local palette = palettes[themeSettings.name .. ':' .. themeSettings.type]

local fontName = 'IBM Plex Sans'

beautiful.init {
	fontName = fontName,
	font = fontName .. ' Regular 12',

	barBackground = palette.background
}
