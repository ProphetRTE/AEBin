-----------------------------------------------------------------------------
--	A module repository server that serves module versions and source
--	code over rednet.
--
--	Version: 0.1.2
--	Dependencies: split, json, log
-----------------------------------------------------------------------------

local split = dofile('/modules/split.lua')
local json = dofile('/modules/json.lua')
local log = dofile('/modules/log.lua')

local protocol = 'modules'
local hostname = 'repository'
local modemSide = 'left'

local module = {
	versions = nil,

	-- map action names (first word of a rednet message) to method names
	routes = {
		get = 'getModule',
		versions = 'getVersions'
	},

	--- Initialize the server
	init = function(self)
		term.clear()
		term.setCursorPos(1, 1)
		print('Started module repository server.\n')

		if not self:open() then
			log('No modem found.', 3)
			return
		end

		log('Host set to "' .. hostname .. '" on "' .. protocol .. '" protocol', 2)

		self.versions = self:getLocalVersions()
		log('Loaded versions file', 2)

		log('Awaiting messages...', 2)

		-- await and respond to rednet messsages
		self:listen()
	end,

	--- Retrieves module names and versions from storage
	-- @param self
	-- @returns 	Returns a table containing module names as table keys and 
	--				their version numbers as table values
	getLocalVersions = function(self)
		if not fs.exists('/modules.json') then
			return
		end

		-- open file
		local file = fs.open('/modules.json', 'r')

		-- read file contents
		-- decode JSON into table
		local data = json:decode(file:readAll())
		file:close()

		-- return table
		return data
	end,

	--- Receive and respond to rednet messages
	-- @param self
	listen = function(self)
		while true do
			-- check if message is a valid command
			local senderID, message = rednet.receive(protocol)
			
			local args = split(message)
			local action = args[1]
			
			-- execute method that is mapped to the first word of a rednet message
			if self.routes[action] ~= nil then
				log('Action "' .. action .. '" requested from client ' .. senderID)
				
				local response = self[self.routes[action]](self, args)

				-- if action method returned a response, send it to the client
				if response ~= nil then
					rednet.send(senderID, response, protocol)
				end
			end
		end
	end,

	--- Return the source code of a module
	-- @param self
	-- @param args	Rednet message arguments (message split into a table of words)
	-- @return		If the module exists, returns the source code. Otherwise returns nil.
	getModule = function(self, args)
		if #args <= 1 then 
			log('Error: No module name was provided', 3)
			return
		end

		local moduleName = args[2]

		-- make sure module exists in versions table
		if not self.versions[moduleName] then return end

		-- make sure module exists in /modules
		if not fs.exists('/modules/' .. moduleName .. '.lua') then 
			log('Error: Source file for module "' .. moduleName .. '" does not exist.', 3)
			return 
		end

		-- get source from file
		local file = fs.open('/modules/' .. moduleName .. '.lua', 'r')
		local source = file:readAll()
		file:close()

		-- return source
		return source
	end,

	--- Return a table of versions
	-- @param self
	-- @param args	Rednet message arguments (message split into a table of words)
	-- @return		Returns a table containing module names mapped to their versions
	getVersions = function(self, args)
		self.versions = self:getLocalVersions()
		return json:encode(self.versions)
	end,

	--- Open any modem attached to the computer
	-- @param self
	-- @return		Returns true if successful or false if not
	open = function(self)
		local sides = {'left', 'right', 'front', 'back', 'top', 'bottom'}
		for key, val in ipairs(sides) do
			if peripheral.getType(sides[key]) == 'modem' then
				rednet.open(sides[key])
				rednet.host(protocol, hostname)

				return true
			end
		end

		return false
	end,
}

return function()
	module:init()
end