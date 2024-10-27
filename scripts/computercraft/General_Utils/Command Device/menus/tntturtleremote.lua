local app = ...

return {
	{'Move to Here', function(menu)
		app:moveHere(menu)
	end},

	{'Drop TNT Here', function()
		app:callTurtle()
	end},

	{'Back', function(menu)
		menu:back()
	end}
}