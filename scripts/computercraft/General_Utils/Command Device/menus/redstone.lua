local serverID, protocol = ...

return {
	{'toggle_redstone', function(menu)
		rednet.send(serverID, 'toggle_redstone', protocol)
	end},

	{'Back', function(menu)
		menu:back()
	end}
}