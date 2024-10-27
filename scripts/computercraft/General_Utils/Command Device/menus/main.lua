local serverID, protocol = ...

local menuinterface = dofile('/modules/menuinterface.lua')
local Teleport = dofile('/modules/teleport.lua')

return {
	-- Load gamemode menu
	{'Gamemode', function(menu)
		local title = 'Select a Gamemode' 
		menu:add(title, menuinterface.load('gamemode', serverID, protocol))
		menu:use(title)
	end},

	-- Load the teleport menu
	{'Teleport', function(menu)
		local title = 'Teleport Menu'
		local teleport = Teleport.new(serverID, protocol)
		local teleportMenu = teleport:getMenu()

		if #teleportMenu == 0 then 
			menu:message('teleport.json not found', 2)
			return
		end

		teleportMenu[#teleportMenu+1] = {'Back', function(menu)
			menu:back()
		end}
		
		-- menu:add(title, menuinterface.load('teleport', serverID, protocol))
		menu:add(title, teleportMenu)
		menu:use(title)
	end},

	-- Load the time menu
	{'Time', function(menu)
		local title = 'Set Time'
		menu:add(title, menuinterface.load('time', serverID, protocol))
		menu:use(title)
	end},

	-- Load the weather menu
	{'Weather', function(menu)
		local title = 'Change Weather'
		menu:add(title, menuinterface.load('weather', serverID, protocol))
		menu:use(title)
	end},

	-- Load the tools menu
	{'Tools', function(menu)
		local title = 'Tools'
		menu:add(title, menuinterface.load('tools', serverID, protocol))
		menu:use(title)
	end},

	{'Exit', function(menu)
		menu:back()
	end}
}