local serverID, protocol = ...

return {
	{'Creative', function(menu)
		rednet.send(serverID, 'mode_creative', protocol)
	end},

	{'Survival', function(menu)
		rednet.send(serverID, 'mode_survival', protocol)
	end},

	{'Back', function(menu)
		menu:back()
	end}
}