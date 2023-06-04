local awful = require 'awful'
local base = require 'ui.components.syntax.base'
local beautiful = require 'beautiful'
local bling = require 'libs.bling'
local dpi = beautiful.dpi
local gears = require 'gears'
local helpers = require 'helpers'
local wibox = require 'wibox'
local w = require 'ui.widgets'
local naughty = require 'naughty'
local menugen = require 'menubar.menu_gen'
local rubato = require 'libs.rubato'
local settings = require 'conf.settings'
local sfx = require 'modules.sfx'

local bgcolor = beautiful.bg_sec
local playerctl = bling.signal.playerctl.lib()
local function button(color_focus, icon, size, shape)
	return w.button(icon, {bg = bgcolor, shape = shape, size = size})
end

local widgets = {}

do
	local albumArt = wibox.widget {
		widget = wibox.widget.imagebox,
		resize = true
	}

	local musicArtist = wibox.widget {
		markup = '',
		widget = wibox.widget.textbox
	}

	local musicTitle = wibox.widget {
		markup = '',
		widget = wibox.widget.textbox
	}

	local musicAlbum = wibox.widget {
		markup = '',
		widget = wibox.widget.textbox
	}
	local positionText = wibox.widget {
		markup = '',
		widget = wibox.widget.textbox
	}

	local position = 0
	local musicDisplay = wibox {
		width = dpi(480),
		height = dpi(180),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}
	helpers.hideOnClick(musicDisplay)

	local progressShape = gears.shape.rounded_bar
	local progress = wibox.widget {
		widget = wibox.widget.progressbar,
		forced_height = beautiful.dpi(10),
		shape = progressShape,
		bar_shape = progressShape,
		background_color = beautiful.xcolor9,
	}

	function setupProgressColor(pos, length)
		local posFraction = (pos / length)
		local progressLength = 282
		local progressCur = posFraction * progressLength
		progress.color = string.format('linear:0,0:%s,0:0,%s:%s,%s', math.floor(beautiful.dpi(progressCur)), base.gradientColors[1], math.floor(beautiful.dpi(progressLength)), base.gradientColors[2])
	end

	local progressAnimator = rubato.timed {
		duration = 0.2,
		rate = 60,
		subscribed = function(pos)
			progress.value = pos
			setupProgressColor(pos, progress.max_value)
		end,
		pos = 0,
		easing = rubato.quadratic
	}

	local slider = wibox.widget {
		widget = wibox.widget.slider,
		forced_height = progress.forced_height,
		bar_color = '#00000000'
	}
	slider:connect_signal('property::value', function()
		progressAnimator.target = slider.value
		playerctl:set_position(slider.value)
	end)

	local function scroll(widget)
		return wibox.widget {
			layout = wibox.container.scroll.horizontal,
			step_function = wibox.container.scroll.step_functions.nonlinear_back_and_forth,
			max_size = 50,
			speed = 80,
			widget
		}
	end

	local wrappedMusicArtist = scroll(musicArtist)
	local wrappedMusicTitle = scroll(musicTitle)
	local wrappedMusicAlbum = scroll(musicAlbum)
	local btnSize = beautiful.dpi(19)

	local updateShuffle
	local shuffleState
	local shuffle = w.button('shuffle', {
		bg = bgcolor,
		size = btnSize,
		onClick = function()
			shuffleState = not shuffleState
			playerctl:set_shuffle(shuffleState)
			updateShuffle()
		end
	})

	updateShuffle = function()
		if shuffleState then
			shuffle.color = beautiful.accent
		else
			shuffle.color = beautiful.fg_normal
		end
	end
	
	playerctl:connect_signal('shuffle', function(_, shuff)
		shuffleState = shuff
		updateShuffle()
	end)

	local prev = w.button('skip-previous', {
		bg = bgcolor,
		size = btnSize,
		onClick = function()
			if position >= 5 then
				playerctl:set_position(0)
				position = 0
				progressAnimator.target = 0
				return
			end
			playerctl:previous()
		end
	})

	local playPauseIcons = {'play', 'pause'}
	local playPause = w.button(playPauseIcons[2], {
		bg = bgcolor,
		size = btnSize,
		onClick = function() playerctl:play_pause() end
	})
	local next = w.button('skip-next', {
		bg = bgcolor,
		size = btnSize,
		onClick = function() playerctl:next()
	end})

	local lastArtist
	local lastAlbum
	playerctl:connect_signal('metadata', function (_, title, artist, art, album)
		musicArtist:set_markup_silently(artist)
		wrappedMusicArtist:emit_signal 'widget::redraw_needed'

		musicTitle:set_markup_silently(title)
		wrappedMusicTitle:emit_signal 'widget::redraw_needed'

		musicAlbum:set_markup_silently(helpers.colorize_text(album == '' and '~~~' or album, beautiful.fg_sec))
		wrappedMusicAlbum:emit_signal 'widget::redraw_needed'

		positionText:set_markup_silently(helpers.colorize_text('0:00', beautiful.fg_sec))

		if artist == lastArtist and album == lastAlbum then return end
		lastArtist = artist
		lastAlbum = album
		albumArt.image = gears.surface.load_uncached_silently(art, beautiful.config_path .. '/images/albumPlaceholder.png')
	end)

	playerctl:connect_signal('position', function (_, pos, length)
		progress.max_value = length
		slider.maximum = length
		progressAnimator.target = pos
		position = pos

		local mins = math.floor(pos / 60)
		local secs = math.floor(pos % 60)
		local time = string.format('%01d:%02d', mins, secs)
		positionText:set_markup_silently(helpers.colorize_text(time, beautiful.fg_sec))
	end)
	playerctl:connect_signal('playback_status', function(_, playing)
		if not playing then
			playPause.icon = playPauseIcons[1]
		else
			playPause.icon = playPauseIcons[2]
		end
	end)

	local info = wibox.widget {
		layout = wibox.layout.align.vertical,
		{
			layout = wibox.layout.fixed.vertical,
			spacing = 6,
			wrappedMusicArtist,
			wrappedMusicTitle,
			wrappedMusicAlbum,
		},
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			{
				widget = wibox.container.margin,
				left = -beautiful.dpi(6),
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = beautiful.wibar_spacing / beautiful.dpi(4),
					prev,
					playPause,
					next
				}
			},
			{
				layout = wibox.container.place
			},
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				shuffle,
				positionText
			}
		},
		{
			layout = wibox.layout.stack,
			progress,
			slider
		}
	}
	--info:ajust_ratio(2, 0.45, 0.15, 0.4)
	--info:ajust_ratio(3, 0.75, 0.25, 0)

	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		base.sideDecor {
			h = 180,
			bg = bgcolor
		},
		{
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, true, true, false, base.radius) end,
			bg = bgcolor,
			widget = wibox.container.background,
			forced_width = musicDisplay.width - (base.width * 2),
			forced_height = musicDisplay.height,
			{
				widget = wibox.container.margin,
				top = 20, left = 20 - (base.widths.empty + base.widths.round), right = 20, bottom = 20,
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = 18,
					{
						widget = wibox.container.constraint,
						width = 140,
						albumArt
					},
					info
				}
			}
		}
	}
	musicDisplay:setup {
		layout = wibox.container.place,
		realWidget
	}

	widgets.musicDisplay = {}
	function widgets.musicDisplay.toggle()
		if not musicDisplay.visible then
			awful.placement.under_mouse(musicDisplay)
		end
		musicDisplay.visible = not musicDisplay.visible -- invert
	end
end

do
	local powerMenu = wibox {
		width = dpi(520),
		height = dpi(200),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}
	local function hide()
		powerMenu.visible = false
		awful.keygrabber.stop()
	end

	local powerText = wibox.widget {
		widget = wibox.widget.textbox,
		markup = helpers.colorize_text('Power Options Menu', beautiful.fg_sec),
		font = 'SF Pro Display 20'
	}
	local function setupDisplayers(set)
		for i, widget in ipairs(set) do
			if i % 2 ~= 0 then
				widget:connect_signal('mouse::enter', function() powerText.markup = helpers.colorize_text(set[i + 1], beautiful.fg_sec) end)
			end
		end
	end

	local function btn(bc, ic, icf)
		return button(bc, ic, 58, helpers.rrect(base.radius))
	end
	local buttonColor = beautiful.fg_normal
	local logout = btn(buttonColor, 'logout')

	logout:connect_signal('button::press', function()
		awesome.quit()
		hide()
	end)

	local shutdown = btn(buttonColor, 'power2')
	shutdown:connect_signal('button::press', function()
		awful.spawn 'poweroff'
		hide()
	end)
	local restart = btn(buttonColor, 'restart')
	restart:connect_signal('button::press', function()
		awful.spawn 'reboot'
		hide()
	end)
	local sleep = btn(buttonColor, 'sleep')
	sleep:connect_signal('button::press', function()
		awful.spawn 'systemctl suspend'
		hide()
	end)
	setupDisplayers {
		logout,
		'Logout',
		shutdown,
		'Shutdown',
		restart,
		'Restart',
		sleep,
		'Sleep'
	}

	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		{
			widget = wibox.container.background,
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, false, true, base.radius) end,
			bg = bgcolor,
			forced_width = powerMenu.width - dpi(base.width),
			{
				widget = wibox.container.margin,
				left = dpi(base.width),
				{
					layout = wibox.layout.align.vertical,
					{
						layout = wibox.container.place
					},
					{
						widget = wibox.container.margin,
						top = beautiful.dpi(8), bottom = beautiful.dpi(8),
						{
							layout = wibox.layout.flex.horizontal,
							logout,
							shutdown,
							restart,
							sleep
						}
					},
					{
						widget = wibox.container.margin,
						bottom = 12,
						right = dpi(base.width) / 2,
						{
							layout = wibox.layout.fixed.vertical,
							spacing = 12,
							{
								widget = wibox.widget.separator,
								forced_height = 1,
								thickness = 1,
								orientation = 'horizontal',
								color = beautiful.fg_sec
							},
							{
								layout = wibox.layout.align.horizontal,
								expand = 'none',
								{
									layout = wibox.layout.fixed.horizontal,
									spacing = 8,
									{
										layout = wibox.container.place,
										valign = 'center',
										{
											widget = wibox.container.constraint,
											width = 22,
											w.imgwidget 'grey-logo.png'
										}
									},
									powerText
								},
								--[[
								{
									layout = wibox.container.place
								},
								{
									widget = wibox.widget.textbox,
									markup = helpers.colorize_text(string.format('Goodbye, %s. What would you like to do?', os.getenv 'USER' or user), beautiful.fg_sec)
								}
								]]--
							}
						}
					}
				}
			}
		},
		base.sideDecor {
			h = powerMenu.height,
			position = 'right',
			bg = bgcolor
		},
	}
	realWidget:connect_signal('mouse::leave', function()
		powerText.markup = helpers.colorize_text('Power Options Menu', beautiful.fg_sec)
	end)

	powerMenu:setup {
		layout = wibox.container.place,
		realWidget
	}

	widgets.powerMenu = {}
	function widgets.powerMenu.toggle()
		if not powerMenu.visible then
			awful.placement.centered(powerMenu, {parent = awful.screen.focused()})
			awful.keygrabber.run(function(_, _, event)
				if event == 'release' then return end
				hide()
			end)
		end

		powerMenu.visible = not powerMenu.visible
	end
end

do
	local startMenu = wibox {
		height = dpi(580),
		width = dpi(460),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}

	local result = {}
	local allApps = {}
	local appList = wibox.layout.overflow.vertical()
	appList.spacing = 1
	appList.step = 25
	appList.scrollbar_widget = {
		{
			widget = wibox.widget.separator,
			shape = gears.shape.rounded_bar,
			color = beautiful.xcolor11
		},
		widget = wibox.container.margin,
		left = dpi(5),
	}
	appList.scrollbar_width = dpi(14)

	menugen.generate(function(entries)
		-- Add category icons
		for k, v in pairs(menugen.all_categories) do
			table.insert(result, { k, {}, v.icon })
		end

		-- Get items table
		for k, v in pairs(entries) do
			for _, cat in pairs(result) do
				if cat[1] == v.category then
					table.insert(cat[2], {v.name, v.cmdline, v.icon})
					allApps[v.name] = {v.cmdline, v.icon}
					break
				end
			end
		end

		local function pairsByKeys (t, f)
			local a = {}
			for n in pairs(t) do table.insert(a, n) end
			table.sort(a, f)
			local i = 0      -- iterator variable
			local iter = function ()   -- iterator function
				i = i + 1
				if a[i] == nil then return nil
				else return a[i], t[a[i]]
				end
			end
			return iter
		end

--		for i = #result, 1, -1 do
--			local v = result[i]
--			if #v[2] == 0 then
--				-- Remove unused categories
--				table.remove(result, i)
--			else
--				table.sort(v[2], function(a, b) return string.lower(a[1]) < string.lower(b[1]) end)
--				v[1] = menugen.all_categories[v[1]].name
--			end
--		end

		-- Sort categories alphabetically also
		--table.sort(result, function(a, b) return string.byte(string.lower(a[1])) < string.byte(string.lower(b[1])) end)

		for name, props in pairsByKeys(allApps, function(a, b) return string.lower(a) < string.lower(b) end) do
			local wid = wibox.widget {
				widget = wibox.container.background,
				shape = helpers.rrect(base.radius),
				id = 'bg',
				bg = bgcolor,
				{
					widget = wibox.container.margin,
					margins = dpi(4),
					{	
						layout = wibox.layout.fixed.horizontal,
						spacing = dpi(8),
						{
							{
								widget = wibox.widget.imagebox,
								image = props[2]
							},
							widget = wibox.container.constraint,
							strategy = 'exact',
							width = 32,
							height = 32
						},
						{
							widget = wibox.widget.textbox,
							align = 'center',
							halign = 'center',
							valign = 'center',
							markup = name
						}
					}
				}
			}
			wid.buttons = {
				awful.button({}, 1, function()
					awful.spawn(props[1])
					widgets.startMenu.toggle()
				end)
			}
			helpers.displayClickable(wid, {bg = bgcolor})
			appList:add(wid)
		end
	end)

	local power = button(buttonColor, 'power2', beautiful.dpi(18))
	power:connect_signal('button::press', function()
		widgets.powerMenu.toggle()
	end)

	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		{
			widget = wibox.container.background,
			bg = bgcolor,
			forced_width = startMenu.width,
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, true, true, base.radius) end,
			{
				widget = wibox.container.margin,
				margins = dpi(5),
				{
					layout = wibox.layout.align.vertical,
					{
						widget = wibox.widget.textbox,
						markup = helpers.colorize_text('Applications', beautiful.fg_normal),
						font = beautiful.font:gsub('%d+$', '24')
					},
					{
						widget = wibox.container.margin,
						bottom = dpi(5),
						appList
					},
					{
						layout = wibox.layout.align.horizontal,
						expand = 'none',
						{
							layout = wibox.layout.fixed.horizontal,
							spacing = dpi(5),
							{
								w.imgwidget('avatar.jpg', {
									clip_shape = gears.shape.circle
								}),
								widget = wibox.container.constraint,
								strategy = 'exact',
								width = 24,
								height = 24
							},
							{
								widget = wibox.widget.textbox,
								text = os.getenv 'USER'
							}
						},
						{
							layout = wibox.layout.fixed.horizontal,
						},
						power
					}
				}
			}
		},
	}

	startMenu:setup {
		layout = wibox.layout.stack,
		base.sideDecor {
			h = startMenu.height,
			position = 'top',
			bg = bgcolor,
			emptyLen = base.width / dpi(2)
		},
		{
			widget = wibox.container.margin,
			top = base.width / dpi(2),
			realWidget,
		}
	}

	local scr = awful.screen.focused()
	local animator = rubato.timed {
		duration = 0.4,
		rate = 60,
		subscribed = function(y)
			startMenu.y = y
		end,
		pos = scr.geometry.height,
		easing = rubato.linear
	}

	local function doPlacement()
		awful.placement.bottom_left(startMenu, {
			margins = {
				left = beautiful.useless_gap * dpi(2),
				bottom = settings.noAnimate and beautiful.wibar_height + beautiful.useless_gap * dpi(2) or -startMenu.height
			},
			parent = awful.screen.focused()
		})
	end
	doPlacement()
	if not settings.noAnimate then startMenu.visible = true end

	local startMenuOpen = false
	widgets.startMenu = {}
	function widgets.startMenu.toggle()
		appList.scroll_factor = 0
		if settings.noAnimate then
			doPlacement()
			startMenu.visible = not startMenu.visible
		else
			if startMenuOpen then
				animator.target = scr.geometry.height
			else
				animator.target = scr.geometry.height - (beautiful.wibar_height + beautiful.useless_gap * dpi(2)) - startMenu.height
			end
			startMenuOpen = not startMenuOpen
		end
	end

	if settings.noAnimate then
		helpers.hideOnClick(startMenu)
	else
		helpers.hideOnClick(startMenu, settings.noAnimate and nil or function()
			if startMenuOpen then
				widgets.startMenu.toggle()
			end
		end)
	end
end

function slider(opts, onChange)
	opts = opts or {}

	local progressShape = gears.shape.rounded_bar
	local progress = wibox.widget {
		widget = wibox.widget.progressbar,
		shape = progressShape,
		bar_shape = progressShape,
		background_color = beautiful.xcolor9,
		max_value = opts.max or 100,
		id = 'progress'
	}

	local function setupProgressColor(pos, length)
		local posFraction = (pos / length)
		local progressLength = opts.width
		local progressCur = posFraction * progressLength
		progress.color = string.format('linear:0,0:%s,0:0,%s:%s,%s', math.floor(beautiful.dpi(progressCur)), base.gradientColors[1], math.floor(beautiful.dpi(progressLength)), base.gradientColors[2])
		progress.value = pos
	end

	local progressAnimator = rubato.timed {
		duration = 0.3,
		rate = 60,
		subscribed = function(pos)
			setupProgressColor(pos, progress.max_value)
		end,
		pos = 0,
		easing = rubato.quadratic
	}

	local slider = wibox.widget {
		widget = wibox.widget.slider,
		forced_height = progress.forced_height,
		bar_color = '#00000000',
		id = 'slider'
	}
	slider:connect_signal('property::value', function()
		progressAnimator.target = slider.value
		opts.onChange(slider.value)
	end)

	return wibox.widget {
		widget = wibox.container.constraint,
		height = beautiful.dpi(5),
		{
			layout = wibox.layout.stack,
			progress,
			slider
		}
	}, slider, progress
end

local sliderControllers = {
	volume = {
		set = sfx.setVolume,
		get = sfx.get_volume_state
	},
	brightness = {
		set = function() end,
		get = function() end
	}
}

function createSlider(name, opts)
	local sl, slider, progress = slider {width = opts.width, onChange = sliderControllers[name].set}
	sliderControllers[name].get(function(v)
		slider.value = v
	end)

	local wid = wibox.widget {
		widget = wibox.container.place,
		valign = 'center',
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = beautiful.dpi(6),

			w.icon(name, {size = beautiful.dpi(32)}),
			{
				layout = wibox.layout.fixed.vertical,
				{
					font = beautiful.font:gsub('%d+$', '20'),
					widget = wibox.widget.textbox,
					text = name:gsub('^%l', string.upper)
				},
				sl
			}
		}
	}

	return setmetatable({}, {
		__index = function(_, k)
			return wid[k]
		end,
		__newindex = function(_, k, v)
			if k == 'value' then
				slider.value = v
			end
		end
	})
end

do
	local volumeDisplay = wibox {
		width = dpi(280),
		height = dpi(75),
		bg = '#00000000',
		ontop = true,
		visible = false
	}
	local sl = createSlider('volume', {width = volumeDisplay.width})

	local displayTimer = gears.timer {
		timeout = 2,
		single_shot = true,
		callback = function()
			volumeDisplay.visible = false
		end
	}

	local margins = beautiful.dpi(10)
	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		base.sideDecor {
			h = volumeDisplay.width,
			bg = bgcolor,
			position = 'top',
			emptyLen = base.width / dpi(2)
		},
		{
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, true, false, base.radius) end,
			bg = bgcolor,
			widget = wibox.container.background,
			{
				widget = wibox.container.margin,
				margins = margins,
				sl
			}
		},
	}

	volumeDisplay:setup {
		layout = wibox.container.place,
		realWidget
	}

	awesome.connect_signal('syntax::volume', function(volume, mute)
		if volumeDisplay.visible then
			displayTimer:stop()
		end
		displayTimer:start()
		sl.value = volume

		awful.placement.bottom(volumeDisplay, { margins = { bottom = beautiful.wibar_height + (beautiful.useless_gap * dpi(2)) }, parent = awful.screen.focused() })
		volumeDisplay.visible = true
	end)
end

do
	widgets.capsIndicator = {}
	local capsIndicator = wibox {
		width = dpi(280),
		height = dpi(75),
		bg = '#00000000',
		ontop = true,
		visible = false
	}

	local displayTimer = gears.timer {
		timeout = 2,
		single_shot = true,
		callback = function()
			capsIndicator.visible = false
		end
	}

	function widgets.capsIndicator.display(capsStatus)
		local margins = beautiful.dpi(10)
		local realWidget = wibox.widget {
			layout = wibox.layout.fixed.vertical,
			base.sideDecor {
				h = capsIndicator.width,
				bg = bgcolor,
				position = 'top',
				emptyLen = base.width / dpi(2)
			},
			{
				shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, true, false, base.radius) end,
				bg = bgcolor,
				widget = wibox.container.background,
				{
					widget = wibox.container.margin,
					margins = margins,
					{
						widget = wibox.container.place,
						valign = 'center',
						{
							layout = wibox.layout.fixed.horizontal,
							spacing = beautiful.dpi(6),

							w.icon(capsStatus and 'caps-on' or 'caps-off', {size = beautiful.dpi(32)}),
							{
								font = beautiful.font:gsub('%d+$', '24'),
								widget = wibox.widget.textbox,
								text = capsStatus and 'Caps Lock On' or 'Caps Lock Off'
							}
						}
					}
				}
			},
		}

		capsIndicator:setup {
			layout = wibox.container.place,
			realWidget
		}

		if capsIndicator.visible then
			displayTimer:stop()
		end
		displayTimer:start()

		awful.placement.bottom(capsIndicator, { margins = { bottom = beautiful.wibar_height + (beautiful.useless_gap * dpi(2)) }, parent = awful.screen.focused() })
		capsIndicator.visible = true
	end
end

widgets.actionCenter = require 'ui.widgets.syntax.actionCenter'

return widgets
