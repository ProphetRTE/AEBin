-----------------------------------------------------------------------------
--  Creates a teleport menu.
--
--	Version: 1.0.1
-----------------------------------------------------------------------------

local json = dofile('/modules/json.lua')

local locationsFilePath = '/teleport.json'

local module = {
    --- Create an instance of the module
	-- @param self
	-- @param serverID  The ID of the command server
	-- @param protocol  The command server protocol
	-- @return		    Returns this table
    init = function(self, serverID, protocol)
        self.serverID = serverID
        self.protocol = protocol

        return self
    end,

    --- Get a menu representing teleport locations with actions that send teleport commands
    --  to the command server
	-- @param self
	-- @return      Returns a table of menu data
    getMenu = function(self)
        local menu = {}
        local locations = self:getLocations()

        if not locations then
            return
        end

        -- create menu items for each element in menu table
        for name, val in pairs(locations) do
            -- if first element of 'val' table is a number, 'val' contains coordinates
            if type(val[1]) == 'number' then
                menu[#menu+1] = self:createMenuItem(name, val[1], val[2], val[3])
            else
                local submenu = {}
                for n, v in pairs(val) do
                    submenu[#submenu+1] = self:createMenuItem(n, v[1], v[2], v[3])    
                end

                -- add submenu
                menu[#menu+1] = {name .. '...', function(m)
                    m:add(name, submenu)
		            m:use(name)
                end}
            end
        end

        menu[#menu+1] = {'Enter Coordinates...', function(menu)
            term.clear()
            term.setCursorPos(1, 1)

            io.write('X: ')
            local x = io.read()
            io.write('Y: ')
            local y = io.read()
            io.write('Z: ')
            local z = io.read()

            if x and y and z then
                rednet.send(self.serverID, 'tp ' .. x .. ' ' .. y .. ' ' .. z, self.protocol)
            end
        end}

        return menu
    end,

    --- Get teleport location data from file
	-- @param self
	-- @return      Returns a table of teleport locations
    getLocations = function(self)
		if not fs.exists(locationsFilePath) then
			return
		end

		-- open file
		local file = fs.open(locationsFilePath, 'r')

		-- read file contents
		-- decode JSON into table
		local data = json:decode(file:readAll())
		file:close()

		return data
	end,

    --- Create a menu item that sends a teleport command to the command server via rednet RPC
	-- @param self
	-- @param name  Location name
	-- @param x     X coordinate
    -- @param y     Y coordinate
    -- @param z     Z coordinate        
	-- @return      Returns a menu item
    createMenuItem = function(self, name, x, y, z)
        return {name, function()
            rednet.send(self.serverID, 'tp ' .. x .. ' ' .. y .. ' ' .. z, self.protocol)
        end}
    end
}

return {
    new = function(serverID, protocol)
        return module:init(serverID, protocol)
    end
}