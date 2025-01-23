-----------------------------------------------------------------------------
--	Checks for newer module versions and downloads updates.
--
--	Version: 1.1.2
--	Dependencies: json
-----------------------------------------------------------------------------

local json = dofile('/modules/json.lua')

local versionsPath = '/modules.json'
local protocol = 'modules'
local hostname = 'repository'

local module = {
	serverID = nil,
	versions = nil,

	--- Initialize the module
	-- @param self
	init = function(self)
		print('Checking for updates...')

		if not self.openRednet() then
			print('Failed to update - no modem attached to this computer.')
			sleep(1)
			return
		end

		-- look up 'repository' computer
		self.serverID = self:getRepositoryServerID()

		if not self.serverID then
			print('Failed to reach repository server.')
			sleep(1)
			return
		end

		-- read /modules.json file and load JSON data into versions table
		self.versions = self:getLocalVersions()

		if not self.versions then
			print('Failed to check for updates - modules.json was not found.')
			sleep(1)
			return
		end

		-- send /modules.json file contents to repository server
		-- receive message from repository server containing the latest versions
		local repositoryVersions = self:getRepositoryVersions()

		if not repositoryVersions then
			print('Failed to reach repository server.')
			sleep(1)
			return
		end

		-- get names of modules whose local versions do not match latest versions
		local oldModules = self:getOutdatedModules(repositoryVersions)

		-- if array of names is greater than 0, prompt the user to update the system or ignore
		if #oldModules == 0 then
			print('System is up-to-date.')
			return
		end

		-- prompt user for update
		if not self:prompt(oldModules) then 
			return
		end

		self:update(oldModules, repositoryVersions)

		-- save versions table to /modules.json
		self:saveVersions()
	end,

	prompt = function(self, oldModules)
		term.clear()
		term.setCursorPos(1, 1)

		io.write(#oldModules .. ' updates available. Update? (y/n): ')

		local answer = io.read()

		return answer == 'y'
	end,

	--- Opens rednet on the attached modem
	--  @return 	Returns true if successful or false if not
	openRednet = function()
		local sides = {'left', 'right', 'front', 'back', 'top', 'bottom'}
		for key, val in ipairs(sides) do
			if peripheral.getType(sides[key]) == 'modem' then
				rednet.open(sides[key])
				return true
			end
		end

		return false
	end,

	--- Looks up ID of repository host
	-- @parm self
	-- @returns		Returns the ID of the repository computer
	getRepositoryServerID = function(self)
		return rednet.lookup(protocol, hostname)
	end,

	--- Retrieves module names and versions from storage
	-- @param self
	-- @returns 	Returns a table containing module names as table keys and 
	--				their version numbers as table values
	getLocalVersions = function(self)
		if not fs.exists(versionsPath) then
			return
		end

		-- open file
		local file = fs.open(versionsPath, 'r')

		-- read file contents
		-- decode JSON into table
		local data = json:decode(file:readAll())
		file:close()

		-- return table
		return data
	end,

	--- Fetches repository versions of a set of modules
	-- @param self
	-- @returns 		A table of module names and their repository versions
	getRepositoryVersions = function(self)
		local message = 'versions'
		for name, version in pairs(self.versions) do
			message = message .. ' ' .. name
		end

		-- send rednet message to repository server
		rednet.send(self.serverID, message, protocol)

		-- receive response
		local senderID, response = rednet.receive(protocol, 2)

		if not senderID then return end

		return json:decode(response)
	end,

	getOutdatedModules = function(self, repositoryVersions)
		local modules = {}
		local i = 1

		-- iterate through all local module versions
		for module, version in pairs(self.versions) do
			local uninstalled = not fs.exists('/modules/' .. module .. '.lua')

			-- if local version doesn't match repository version, add name to table
			if uninstalled or (repositoryVersions[module] ~= nil and version ~= repositoryVersions[module]) then
				modules[i] = module
				i = i + 1
			end
		end

		return modules
	end,

	--- Fetches the source code of a module from the repository
	-- @param self
	-- @param name 	Module name
	-- @returns 	Returns source code of the module
	getModule = function(self, name)
		rednet.send(self.serverID, 'get ' .. name, protocol)
		local senderID, message = rednet.receive(protocol, 2)
		return message
	end,

	--- Writes source code to a module file
	-- @param self
	-- @param name 		Module name
	-- @param source 	Module source code
	writeModule = function(self, name, source)
		local path = '/modules/' .. name .. '.lua'

		-- open file for reaching
		local file = fs.open(path, 'w')
		file.write(source)
		file.close()
	end,

	--- Writes the versions table to the modules.json file
	-- @param self
	saveVersions = function(self)
		-- make sure file exists
		if not fs.exists(versionsPath) then return end

		-- open file for reaching
		local file = fs.open(versionsPath, 'w')
		file.write(json:encode(self.versions))
		file.close()
	end,

	--- Write updated source code to all outdated modules
	-- @param self
	-- @param oldModules	A table containing names of outdated modules
	update = function(self, oldModules, repositoryVersions)
		print('Updating...')
	
		-- for each of those module names, send a rednet message requesting the source of the latest version
		for key, moduleName in ipairs(oldModules) do
			local source = self:getModule(moduleName)

			if not source then
				print('Failed to update module ' .. moduleName)
			else
				-- save response message into the /modules directory as the module name
				self:writeModule(moduleName, source)

				-- update the versions table
				self.versions[moduleName] = repositoryVersions[moduleName]

				print('Updated module "' .. moduleName .. '" to v' .. self.versions[moduleName])
			end
		end
	end
}

return function()
	module:init()
end