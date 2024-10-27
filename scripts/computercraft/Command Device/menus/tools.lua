local serverID, protocol = ...

local rpcclient = dofile('/modules/rpcclient.lua')
local tntturtleremote = dofile('/modules/tntturtleremote.lua')

return {
	{'Lua Console', function()
		term.clear()
		term.setCursorPos(1, 1)
		shell.run("lua")
	end},

	{'RPC Client', function(menu)
		rpcclient(nil, menu)
	end},

	{'TNT Turtle Remote', function(menu)
		tntturtleremote(menu)
	end},

	{'Restart Command Server', function(menu)
		rednet.send(serverID, 'restart', protocol)
		menu:message('Server restarted.', 2)
	end},

	{'Test Network Range', function(menu)
		while true do
			rednet.broadcast('ping')
			local senderID, msg, distance = rednet.receive(nil, 1)

			if senderID then
				menu:message('In range.')
				sleep(1)
			else
				menu:message('Out of range.')
			end
		end
	end},

	{'Back', function(menu)
		menu:back()
	end}

}