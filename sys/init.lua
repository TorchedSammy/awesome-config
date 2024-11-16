local gfs = require 'gears.filesystem'
local settings = require 'sys.settings'

-- Initialize settings stores
settings.defineType('wallpaper', {
	home = {
		tiled = false,
		acrossScreens = false,
		image = gfs.get_configuration_dir() .. 'wallpapers/aster.png'
	},
	lock = {
		tiled = false,
		acrossScreens = false,
		image = gfs.get_configuration_dir() .. 'wallpapers/aster.png'
	},
})

settings.defineType('theme', {
	name = 'harmony',
	type = 'dark'
})

settings.defineType('bars', {
	{
		screen = 'all',
		height = 36,
		position = 'bottom',
		shape = 'rectangle',
		modules = {
			left = {
				'startMenu'
			},
			center = {},
			right = {
				'time'
			}
		}
	}
})
