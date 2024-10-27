local serverID, protocol = ...

return {
	{'Clear', function()
		rednet.send(serverID, 'weather_clear', protocol)
	end},

	{'Rain', function()
		rednet.send(serverID, 'weather_rain', protocol)
	end},

	{'Thunder', function()
		rednet.send(serverID, 'weather_thunder', protocol)
	end},

	{'Back', function(menu)
		menu:back()
	end}
}