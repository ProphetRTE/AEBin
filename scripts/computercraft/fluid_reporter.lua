-- Function to initialize Rednet
local function initRednet()
    rednet.open("top")  -- Change "top" to your connected side (e.g., "left", "right", etc.)
    print("Ready to send requests...")
end

-- Function to request fluid information
local function requestFluidInfo()
    rednet.broadcast({request = "fluid_info"})
end

-- Function to request player status
local function requestPlayerStatus()
    rednet.broadcast({request = "player_status"})
end

-- Main function to send requests
local function main()
    initRednet()
    
    -- Example usage:
    requestFluidInfo()  -- Send request for fluid info
    sleep(5)  -- Wait for 5 seconds before sending another request
    requestPlayerStatus()  -- Send request for player status

    while true do
        local senderId, message = rednet.receive()
        if type(message) == "table" and message.response then
            print("Response from server: " .. message.response)
        end
    end
end

-- Start the client
main()