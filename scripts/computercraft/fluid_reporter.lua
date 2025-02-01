local fluidTypes = {"Water", "Lava", "Other"}
local fluidLevels = {0, 0, 0} -- Levels for Water, Lava, Other
local currentFluidIndex = 1
local maxLevel = 1000 -- Max level for the fluid tanks

-- Function to initialize Rednet
local function initRednet()
    rednet.open("top")  -- Change "top" to your connected side (e.g., "left", "right", etc.)
    print("Ready to send requests...")
end

-- Function to request fluid info
local function requestFluidInfo()
    rednet.broadcast({request = "fluid_info"})
end

-- Function to display the fluid levels
local function displayFluidLevels()
    term.clear() -- Clear the terminal
    term.setCursorPos(1, 1)
    print("Fluid Levels:")
    for i, fluid in ipairs(fluidTypes) do
        local level = fluidLevels[i]
        -- Calculate length of the bar based on the level (adjust multiplier based on your needs)
        local barLength = (level / maxLevel) * 20
        local bar = string.rep("=", barLength) .. string.rep(" ", 20 - barLength) -- 20 character width
        if i == currentFluidIndex then
            print("[" .. fluid .. "] " .. bar .. " " .. level .. " mB <==")
        else
            print("[" .. fluid .. "] " .. bar .. " " .. level .. " mB")
        end
    end
end

-- Function to handle received fluid info
local function handleFluidInfo(message)
    if type(message) == "table" and message.fluidLevels then
        for i, level in ipairs(message.fluidLevels) do
            fluidLevels[i] = level
        end
    end
end

-- Function to scroll through fluid types
local function scrollFluids(key)
    if key == keys.up then
        currentFluidIndex = currentFluidIndex - 1
        if currentFluidIndex < 1 then
            currentFluidIndex = #fluidTypes
        end
    elseif key == keys.down then
        currentFluidIndex = currentFluidIndex + 1
        if currentFluidIndex > #fluidTypes then
            currentFluidIndex = 1
        end
    end
end

-- Main function to run the client
local function main()
    initRednet()

    -- Initial request for fluid info
    requestFluidInfo()

    while true do
        displayFluidLevels()

        local event, key = os.pullEvent("key")
        scrollFluids(key)

        -- Look for response from server
        local senderId, message = rednet.receive()
        handleFluidInfo(message)
    end
end

-- Start the fluid reporter
main()