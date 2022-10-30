local colors = require 'themes.colors.stardew-night'
if not awesome then return colors end

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = require('themes.common')

-- join theme and colors
local gears = require 'gears'
theme = gears.table.join(theme, colors)

theme.bg_normal     = theme.xbackground
theme.bg_sec        = '#6F6F70'
theme.bg_focus      = theme.bg_normal
theme.bg_urgent     = theme.bg_normal
theme.bg_minimize   = theme.bg_normal

theme.fg_normal     = theme.xforeground

theme.useless_gap   = dpi(10)
theme.border_width  = dpi(6)
theme.border_normal  = theme.bg_normal -- Outer Border
theme.border_focus  = theme.bg_normal -- Outer Border
theme.titlebar_bg  = theme.xcolor6 -- Inner Border

theme.titlebars = true
theme.titlebar_type = 'default'

theme.bar = 'clouds'
theme.wibar_bg = theme.bg_normal
theme.wibar_spacing = dpi(14)

theme.notification_border_color = theme.titlebar_bg
theme.notification_border_width = theme.border_width
theme.notification_position = 'bottom_right'
theme.notification_padding = dpi(45)
theme.notification_spacing = dpi(8)
theme.notification_shape = nil

theme.taglist_text_color_empty    = { theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7 }
theme.taglist_text_color_occupied  = { theme.xcolor1, theme.xcolor2, theme.xcolor3, theme.xcolor4, theme.xcolor5, theme.xcolor6, theme.xcolor1, theme.xcolor2, theme.xcolor3, theme.xcolor4 }
theme.taglist_text_color_focused  = { theme.xcolor1, theme.xcolor2, theme.xcolor3, theme.xcolor4, theme.xcolor5, theme.xcolor6, theme.xcolor1, theme.xcolor2, theme.xcolor3, theme.xcolor4 }
theme.taglist_text_color_urgent   = { theme.xcolor9, theme.xcolor10, theme.xcolor11, theme.xcolor12, theme.xcolor13, theme.xcolor14, theme.xcolor9, theme.xcolor10, theme.xcolor11, theme.xcolor12 }

theme.bg_systray = theme.wibar_bg

theme.wallpaper = theme.config_path.."/wallpapers/clouds1.jpg"

theme.picom_conf = "rounded"

theme.double_borders = true

return theme

