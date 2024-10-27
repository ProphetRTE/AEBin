-----------------------------------------------------------------------------
--	An RPC server that executes procedures requested over the rednet 'rpc'
--	protocol.
--
--	Version: 0.4.15
--	Dependencies: log, split
-----------------------------------------------------------------------------

local log = dofile('/modules/log.lua')
local split = dofile('/modules/split.lua')

local rednetrpc = {
	
	-- rednet host info
	protocol = 'rpc',
	hostname = 'rpc_server',
	
	-- procedures table
	procedures = {},

	-- indicates if the application is listening for procedure calls over rednet
	listening = false,

	--- Initialize server
	-- @param self
	-- @param procedures	(Optional) A table of procedure functions to register
	-- @param hostname		(Optional) A rednet hostname. Defaults to 'rpc_server'.
	-- @return				Returns the server instance
	init = function(self, procedures, hostname)
		self.hostname = hostname or self.hostname
		
		-- open rednet
		if not self:open() then
			log('Error: No modem attached to this computer.', 3)
			return
		end

		term.clear()
		print('Started RPC server on protocol "' .. self.protocol .. '" using hostname "' .. self.hostname .. '".\n')

		-- register procedures, if provided
		if procedures ~= nil then 
			self:registerProcedures(procedures)
		end

		-- if procedures.lua file exists, register its procedures
		if fs.exists('/procedures.lua') then
			local data = dofile('/procedures.lua')
			if type(data) == 'table' then
				self:registerProcedures(data)
			end
		end

		self:registerHelpProcedures()

		return self
	end,

	--- Add a table of functions to the procedures table
	-- @param self
	-- @param procedures	A table of functions to register as procedures
	registerProcedures = function(self, procedures)
		for name, func in pairs(procedures) do
			self.procedures[name] = func
			log('Registered procedure ' .. name)
		end
	end,

	--- Register a 'help' procedure to return a list of all registered procedures
	-- @param self
	registerHelpProcedures = function(self)
		local list = function(args)
			local msg = ''
			for key, val in pairs(self.procedures) do
				msg = msg .. '\t ' .. key .. '\n'
			end
			return msg
		end

		self.procedures['help'] = list
	end,

	--- Open any modem attached to the computer
	-- @param self
	-- @return		Returns true if successful or false if not
	open = function(self)
		local sides = {'left', 'right', 'front', 'back', 'top', 'bottom'}
		for key, val in ipairs(sides) do
			if peripheral.getType(sides[key]) == 'modem' then
				rednet.open(sides[key])
				rednet.host(self.protocol, self.hostname)

				return true
			end
		end

		return false
	end,

	--- Start loop to receive and respond to rednet RPC messages
	-- @param self
	listen = function(self)
		self.listening = true

		while self.listening do
			local senderID, msg, protocol = rednet.receive()

			local args = split(msg)

			-- if a protocol has been specified, ignore procedureName if it isn't on the correct protocol
			if self.protocol == nil or (self.protocol ~= nil and protocol == self.protocol) then
				log('Computer ' .. senderID .. ': ' .. msg)
				if self.procedures[args[1]] ~= nil then
					local response = self.procedures[args[1]](args)
					log('Procedure "' .. args[1] .. '" called', 2)
					
					-- Return response, if provided
					if response ~= nil then
						rednet.send(senderID, response, protocol)
					end
				else
					rednet.send(senderID, 'Unknown procedure', protocol)
				end
			end
		end
	end

}

return {
	--- Initialize and return an instance of the module
	-- @param procedures	(Optional) A table of functions to register as procedures
	-- @param hostname		(Optional) A hostname to use on rednet
	-- @return				Returns the module table
	new = function(procedures, hostname)
		return rednetrpc:init(procedures, hostname)
	end
}