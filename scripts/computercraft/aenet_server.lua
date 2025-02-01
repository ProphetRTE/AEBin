-- Function to initialize Rednet
local function initRednet()
    rednet.open("top")  -- Change "top" to your connected side (e.g., "left", "right", etc.)
    print("Listening for requests...")
end

-- Simulated fluid levels (in millibuckets for example)
local fluidLevels = {
    Water = 500,  -- Example level for Water
    Lava = 300,   -- Example level for Lava
    Other = 150   -- Example level for other fluids (if applicable)
}

-- Function to handle received messages
local function handleMessage(senderId, message)
    if type(message) == "table" and message.request then
        if message.request == "fluid_info" then
            -- Gather fluid info and send it back
            rednet.send(senderId, {
                fluidLevels = {
                    fluidLevels.Water,
                    fluidLevels.Lava,
                    fluidLevels.Other
                }
            })
        elseif message.request == "player_status" then
            -- Example player status; replace with actual logic to gather player status
            local playerStatus = "Player is online and healthy"  -- Example status
            rednet.send(senderId, {response = playerStatus})
        else
            print("Unknown request from ID " .. senderId)
        end
    else
        print("Received invalid message from ID " .. senderId)
    end
end

-- Main loop to listen for messages
local function main()
    while true do
        local senderId, message = rednet.receive()
        handleMessage(senderId, message)
    end
end

-- Initialize and start listening
initRednet()
main()