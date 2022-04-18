local style = require "core.style"
local common = require "core.common"

local oldPackagePath = package.path
package.path = package.path .. ';' .. os.getenv 'HOME' .. '/.config/awesome/?.lua'

local awesomeDir = '~/.config/awesome'
local awmThemename = dofile((awesomeDir .. '/conf/settings.lua'):gsub('~', os.getenv 'HOME')).theme
local themePath = awesomeDir .. '/themes/colors/' .. awmThemename .. '.lua'
local thm = dofile(themePath:gsub('~', os.getenv('HOME')))
local bg = thm.xbackground
local fg = thm.xforeground

package.path = oldPackagePath

if thm.name == 'horizon' then
	local green = thm.xcolor2
	local yellow = thm.xcolor3
	thm.xcolor2 = yellow
	thm.xcolor3 = green
end

for i = 0, 15 do
	style['color' .. i] = {common.color(thm['xcolor' .. i])}
end

style.gitdiff_padding = 4

style.background = { common.color(bg) }
style.background2 = { common.color(bg) }
style.background3 = style.color15
style.text = { common.color(fg) }
style.caret = style.color4
style.accent = style.color14
style.dim = style.color10
style.divider = style.color8
style.selection = style.color10
style.line_number = style.color11
style.line_number2 = style.color7
style.line_highlight = style.color13
style.scrollbar = style.color10
style.scrollbar2 = style.color11

style.syntax["normal"] = { common.color(fg) }
style.syntax["symbol"] = { common.color(fg) }
style.syntax["comment"] = style.color11
style.syntax["keyword"] = { common.color(thm.xcolor5) }
style.syntax["keyword2"] = { common.color(thm.xcolor6) }
style.syntax["number"] = style.color1
style.syntax["literal"] = style.color2
style.syntax["string"] = { common.color(thm.xcolor2) }
style.syntax["operator"] = { common.color(thm.xcolor3) }
style.syntax["function"] = { common.color(thm.xcolor4) }

style.caret_width = common.round(1.2 * SCALE)
style.gitdiff_addition = {common.color(thm.xcolor2)}
style.gitdiff_modification = {common.color(thm.xcolor4)}
style.gitdiff_deletion = {common.color(thm.xcolor1)}
style.gitdiff_width = 2

style.gitstatus_addition = style.gitdiff_addition
style.gitstatus_modification = style.gitdiff_modification
style.gitstatus_deletion = style.gitdiff_deletion

style.lint = {
	info = style.color14,
	hint = style.color4,
	warning = style.color3,
	error = style.color1
}

style.visu = {
	bars = style.color7
}
