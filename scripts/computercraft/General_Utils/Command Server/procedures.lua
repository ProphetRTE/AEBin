local username = 'AEV1ridis'
local side = "top"

return {
	mode_creative = function()
		commands.exec('gamemode 1 ' .. username)
	end,

	mode_survival = function()
		commands.exec('gamemode 0 ' .. username)
	end,

	time_morning = function()
		commands.exec('time set 0')
		return 'true'
	end,

	time_noon = function()
		commands.exec('time set 6000')
		return 'true'
	end,

	time_evening = function()
		commands.exec('time set 9000')
		return 'true'
	end,

	time_night = function()
		commands.exec('time set 14000')
		return 'true'
	end,

	weather_clear = function()
		commands.exec('weather clear')
		return 'true'
	end,

	weather_rain = function()
		commands.exec('weather rain')
		return 'true'
	end,

	weather_thunder = function()
		commands.exec('weather thunder')
		return 'true'
	end,

	tp = function(args)
		if not args[2] or not args[3] or not args[4] then
			return 'X, Y, and Z coordinates required'
		end

		if not tonumber(args[2]) or not tonumber(args[3]) or not tonumber(args[4]) then
			return 'X, Y, and Z coordinates must be numeric values'
		end

		commands.exec('tp ' .. username .. ' ' .. args[2] .. ' ' .. args[3] .. ' ' .. args[4])
		return 'true'
	end,

	restart = function()
		os.reboot()
	end,

	toggle_redstone = function()
		local isToggled = redstone.getOutput(side)
		if redstoneSide == nil then
			print("Command needs the side to send the redstone signal on.")
			return 'false'
		end
		redstone.setOutput(side,  not isToggled)
		return 'true'
	end
}