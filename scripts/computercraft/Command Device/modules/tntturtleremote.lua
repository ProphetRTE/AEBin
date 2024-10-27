-- v0.2

-- install any missing modules
(dofile('/modules/install.lua'))('split', 'menuinterface', 'log', 'repositoryserver')

local split = dofile('/modules/split.lua')
local menuinterface = dofile('/modules/menuinterface.lua')
local log = dofile('/modules/log.lua')

local protocol = 'rpc'

local module = {
	menu = nil,

	init = function(self, menu)
		local title = 'TNT Turtle'

		-- load menu and pass it a reference to this module
		menu:add(title, menuinterface.load('tntturtleremote', self))

		menu:use(title)
	end,

	callTurtle = function(self)
		local x, y, z = nil

		while not x do
			x, y, z = gps.locate()
		end

		rednet.broadcast('bomb ' .. x .. ' ' .. y .. ' ' .. z, protocol)

		self.listen()
	end,

	moveHere = function(self, menu)
		local x, y, z = nil

		while not x do
			x, y, z = gps.locate()
		end

		rednet.broadcast('move ' .. x .. ' ' .. y .. ' ' .. z, protocol)

		menu:message('Turtle called', 2)
	end,

	listen = function()
		term.clear()
		term.setCursorPos(1, 1)

		print('* TNT turtle inbound...')

		while true do
			local senderID, msg = rednet.receive(protocol)

			if msg == 'ok' then return end

			print('* ' .. msg)
		end
	end,
}

return function(menu)
	module:init(menu)
end