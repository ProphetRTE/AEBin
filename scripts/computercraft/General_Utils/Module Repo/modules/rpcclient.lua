-----------------------------------------------------------------------------
--  Provides a console for interaction with a rednet RPC server.
--
--	Version: 0.3.1
--	Dependencies: log, menuinterface
-----------------------------------------------------------------------------

local log = dofile('/modules/log.lua')
local menuinterface = dofile('/modules/menuinterface.lua')

local protocol = 'rpc'

local module = {
	-- @param hostname 	(Optional) A rednet host to lookup
	-- @param menu 		(Optional) A menu instance for the module to pass menu data to
	init = function(self, hostname, menu)
		if menu then
			menu:message('Looking up hosts...')
		end

		-- do a lookup of all computers on 'rpc' protocol, and hostname if one is provided
		local computerIDs = {rednet.lookup(protocol, hostname)}

		if menu then
			menu:message('')
		end

		-- if multiple hosts are found, display their IDs in a menu for the user to select
		if #computerIDs > 1 then
			self:selectHost(computerIDs, menu)
			return
		end

		-- display error message if no hosts were found
		if #computerIDs == 0 then
			-- display message on menu, if menu was provided
			if menu then
				menu:message('No RPC host found', 3)
				return
			end

			-- otherwise print message
			print('No RPC host found.')
			io.read()
			return
		end

		-- begin loop to prompt user for RPC command
		self:prompt(computerIDs[1])
	end,

	selectHost = function(self, computerIDs, menu)
		menu = menu or menuinterface.new()
		local menuData = {}

		-- build menu data using computer IDs as options
		for i=1, #computerIDs do
			local id = computerIDs[i]
			menuData[i] = {id, function(menu)
				self:prompt(id)
				menu:back()
			end}
		end

		-- display menu
		menu:add('Select RPC Host', menuData)
		menu:use('Select RPC Host')
	end,

	prompt = function(self, computerID)
		term.clear()
		term.setCursorPos(1, 1)

		print('Connected to computer ' .. computerID .. '.')
		print('\nType "exit" to exit the RPC prompt.')
		print('Type "list" to see procedures.')
		
		term.setTextColor(colors.white)

		while true do
			io.write(computerID .. '> ')
			
			local input = io.read()
			if input ~= '' then
				if input == 'exit' then return end

				rednet.send(computerID, input, protocol)

				local senderID, response = rednet.receive(protocol, 1)
				if response ~= nil then
					print(response)
				end
			end
		end
	end
}


return function(hostname, menu)
	module:init(hostname, menu)
end