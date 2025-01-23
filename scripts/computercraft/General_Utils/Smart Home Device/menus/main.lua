local serverID, protocol = ...

local menuinterface = dofile('/modules/menuinterface.lua')
local Teleport = dofile('/modules/teleport.lua')

return {
	-- Load Lights menu
	{'Lights', function(menu)
		local title = 'Turn on lights!' 
		menu:add(title, menuinterface.load('lights', serverID, protocol))
		menu:use(title)
	end},

	{'Exit', function(menu)
		menu:back()
	end}
}