-- Function to initialize Rednet
local function initRednet()
    rednet.open("top")  -- Change "top" to your connected side (e.g., "left", "right", etc.)
    print("Listening for requests...")
end

-- Function to handle received messages
local function handleMessage(senderId, message)
    if type(message) == "table" and message.request then
        if message.request == "fluid_info" then
            -- Here, you would call a function to gather fluid info
            local fluidInfo = "Sample fluid info"  -- Replace with actual fluid info retrieval logic
            rednet.send(senderId, {response = fluidInfo})
        elseif message.request == "player_status" then
            -- Here, you would gather player status
            local playerStatus = "Player status data"  -- Replace with actual player status retrieval logic
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