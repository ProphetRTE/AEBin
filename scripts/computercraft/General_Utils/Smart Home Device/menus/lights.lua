local serverID, protocol = ...

return {
	{'HQ Lights', function(menu)
		rednet.send(serverID, 'lights_hq', protocol)
	end},

	{'Workshop Lights', function(menu)
		rednet.send(serverID, 'lights_ws', protocol)
	end},

	{'Back', function(menu)
		menu:back()
	end}
}