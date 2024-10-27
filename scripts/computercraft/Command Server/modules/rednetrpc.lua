-----------------------------------------------------------------------------
--	An RPC server that executes procedures requested over the rednet 'rpc'
--	protocol.
--
--	Version: 0.4.14
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

	init = function(self, procedures, hostname)
		local hostnameMsg = ''

		if hostname ~= nil then 
			self.hostname = hostname
			hostnameMsg = ' using hostname "' .. hostname .. '"'
		end

		-- open rednet
		if not self:open() then
			return
		end

		term.clear()
		print('Started RPC server' .. hostnameMsg)
		print()

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

	registerProcedures = function(self, procedures)
		for name, func in pairs(procedures) do
			self.procedures[name] = func
			log('Registered procedure ' .. name)
		end
	end,

	registerHelpProcedures = function(self)
		local list = function(args)
			local msg = ''
			for key, val in pairs(self.procedures) do
				msg = msg .. '\t ' .. key .. '\n'
			end
			return msg
		end

		self.procedures['procedures'] = list
		self.procedures['list'] = list
		self.procedures['help'] = list 
	end,

	open = function(self)
		local sides = {'left', 'right', 'front', 'back', 'top', 'bottom'}
		for key, val in ipairs(sides) do
			if peripheral.getType(sides[key]) == 'modem' then
				rednet.open(sides[key])
				rednet.host(self.protocol, self.hostname)

				return true
			end
		end

		log('Error: No modem attached to this computer.', 3)
		return false
	end,

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
	new = function(procedures, hostname)
		return rednetrpc:init(procedures, hostname)
	end
}