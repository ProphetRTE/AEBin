local serverID, protocol = ...

return {
	{'texp', function(menu)
		rednet.send(serverID, 'toggle_redstone', protocol)
	end},
}