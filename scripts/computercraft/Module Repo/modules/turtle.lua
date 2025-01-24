-- v0.1.10

local log = dofile('/modules/log.lua')
local rpc = dofile('/modules/rednetrpc.lua')
local json = dofile('/modules/json.lua')

--- This module controls a turtle in response to RPC commands
local module = {
    data = {
        running = true,
        connected = false,
        computerID = nil,
        direction = 'forward'
    },

    procedures = {
        back = function(args)
            turtle.back()
            return 'true'
        end,

        dig = function(args)
            -- if (self.data.direction == 'up') then
            --     turtle.digUp();
            -- elseif (self.data.direction == 'down') then
            --     turtle.digDown();
            -- else
                turtle.dig()
                return 'true'
            -- end
        end,

        down = function(args)
            turtle.down()
            return 'true'
        end,

        forward = function(args)
            if not turtle.forward() then
                return 'false'
            end

            return 'true'
        end,

        left = function(args)
            turtle.turnLeft()
            return 'true'
        end,

        right = function(args)
            turtle.turnRight()
            return 'true'
        end,

        up = function(args)
            turtle.up()
            return 'true'
        end,

        inventory = function(args)
            local inventory = {}

            for i=1,16 do
                local item = turtle.getItemDetail(i);
                if (item) then
                   inventory[item.name] = i;
                end
            end

            return json:encode(inventory)
        end,

        slot = function(args)
            local slot = tonumber(args[2])

            if not slot or slot > 16 then
                return 'Slot within range of 1 and 16 required'
            end

            turtle.select(tonumber(args[2]));

            return 'true'
        end,

        place = function(args)
            -- if (self.data.direction == 'up') then
            --     turtle.placeUp();
            -- elseif (self.data.direction == 'down') then
            --     turtle.placeDown();
            -- else
                turtle.place()
                return 'true'
            -- end
        end,

        drop = function(args)
            -- if (self.data.direction == 'up') then
            --     turtle.dropUp();
            -- elseif (self.data.direction == 'down') then
            --     turtle.dropDown();
            -- else
                turtle.drop()
                return 'true'
            -- end
        end,

        attack = function(args)
            turtle.attack()
            return 'true'
        end,
    },

    init = function(self, hostname)
        hostname = hostname or 'turtle'

        if not turtle then
            log('TurtleListen can only be run on a Turtle.', 3)
            return
        end

        local server = rpc.new(self.procedures, hostname)
        server:listen()

        term.clear()
        term.setCursorPos(1, 1)
        print('Started turtle RPC server\n')
        -- self:startLoop()

    end,

    startLoop = function(self)
        while (self.data.running) do
            local senderID, message, protocol = rednet.receive('turtle');
            local request = JSON:decode(message);

            self:handleRequest(senderID, request);
        end
    end,

    handleRequest = function(self, senderID, requestData)
        local sendResponse = true;
        local responseData = {};
        local getResponse = false;

        -- handle 'identify' request by returning computer label
        if (requestData.type == 'identify') then
            log('Identity requested by computer ' .. senderID);
            responseData.label = os.getComputerLabel();
            responseData.id = os.getComputerID();
            responseData.success = true;

        -- handle 'connect' request
        elseif (requestData.type == 'connect') then
            log('Connection accepted from computer ' .. senderID);
            self.data.computerID = senderID;
            self.data.connected = true;
            responseData.success = true;

        -- handle 'command' request
        elseif (requestData.type == 'command') then
            -- ensure that turtle is receiving request from connected computer
            if (self.data.connected and self.data.computerID == senderID) then
                -- check if command exists
                if (self.commands[requestData.command] ~= nil) then
                    -- concatenate arguments into string for message output
                    local argsString = '';
                    if (requestData.args ~= nil) then
                        for key, val in pairs(requestData.args) do
                            argsString = argsString .. ' ' .. val;
                        end
                    end
                    log(requestData.command .. argsString);

                    local args = requestData.args or {};
                    self.commands[requestData.command](self, requestData.token, unpack(args));
                else
                    responseData.success = false;
                    responseData.message = 'Unrecognized command.';
                end
            else
                sendResponse = false;
            end

        -- handle 'disconnect' request
        elseif (requestData.type == 'disconnect') then
            if (self.data.connected and self.data.computerID == senderID) then
                log('Computer ' .. senderID .. ' disconnected.');
                print('Waiting for a connection...');
                self.data.connected = false;
                responseData.success = true;
            end
        else
            responseData.success = false;
            responseData.message = 'Invalid request type.';
        end

        if (sendResponse) then
            BaseOS.Turtle:request(senderID, responseData, getResponse, requestData.token);
        end
    end
}

return function(hostname)
    module:init(hostname)
end