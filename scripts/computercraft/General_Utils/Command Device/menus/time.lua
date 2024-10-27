local serverID, protocol = ...

return {
	{'Morning', function()
		rednet.send(serverID, 'time_morning', protocol)
	end},

	{'Noon', function()
		rednet.send(serverID, 'time_noon', protocol)
	end},

	{'Evening', function()
		rednet.send(serverID, 'time_evening', protocol)
	end},

	{'Night', function()
		rednet.send(serverID, 'time_night', protocol)
	end},

	{'Back', function(menu)
		menu:back()
	end}
}