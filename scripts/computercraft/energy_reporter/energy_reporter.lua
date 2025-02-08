os.loadAPI("lib/aeutils")
os.loadAPI("lib/aeprint")

-- Valve, Monitor & Wireless Modem
local mon = peripheral.find("monitor")
local wmod = aeutils.resolveModemSide(nil)
local previousTankInfo = {}
local acceptedEnergyTypes = {
    "create_new_age:carbon_brushes",
}

local formattedOutput = {}
local tankData = {} -- To store data for each bank
local sendFreq = 3  -- Modem Frequency
local content       -- What is in bank?
local sleeptime     -- How long to sleep
local tanksTable    -- Table to hold bank information

-- Set warning lamp to off
redstone.setOutput("right", false)

if not wmod then
    aeprint.aeprint("No modem found!")
    sleep(1)
else
    -- Set modem frequency
    rednet.open(wmod)
    aeprint.aeprint("Modem found, frequency set to " .. sendFreq)
end

-- Function to check if the peripheral type is accepted
local function isAcceptedEnergyType(type)
    for _, acceptedType in ipairs(acceptedEnergyTypes) do
        if type == acceptedType then
            return true
        end
    end
    return false
end

-- Function to display energy information
local function displayEnergyInfo(bank, lineOffset, monitorWidth)
    local energy = bank.getEnergy()
    local capacity = bank.getEnergyCapacity()
    local percentage = capacity > 0 and (energy / capacity) * 100 or 0  -- Avoid division by zero
    local barLength = monitorWidth - 5  -- Width of the bar
    local filledLength = math.floor((percentage / 100) * barLength)
    local energyBar = string.rep("|", filledLength) .. string.rep(".", barLength - filledLength)  -- Use filled and empty blocks
    
    -- Create display string
    return string.format("[%s] %.2f%%", energyBar, percentage)
end

-- Main function to check bank information
local function checkEnergyInfo()
    local peripherals = aeutils.getPeripherals()
    
    if #peripherals == 0 then
        aeprint.aeprint("No peripherals found.")
        if mon then
            mon.clear()
            mon.write("No peripherals found.")
        end
        return
    end

    local isChanged = false
    formattedOutput = {}

    -- Clear the monitor
    if mon then
        mon.clear()
        mon.setCursorPos(1, 1)
    end

    -- Get monitor width for formatting
    local monitorWidth = mon.getSize()  -- Get the monitor width

    -- Header
    if mon then
        mon.setCursorPos(1, 1)
        mon.write(string.rep("=", monitorWidth))  -- Adjust header based on monitor width
    end

    local lineOffset = 2  -- Starting line for bank information display

    -- Iterate through each peripheral to get bank info
    for _, peripheralName in pairs(peripherals) do
        local peripheralType = aeutils.getPeripheralType(peripheralName)

        -- Check if the peripheral type is in the accepted list
        if isAcceptedEnergyType(peripheralType) then
            local energyPeripheral = peripheral.wrap(peripheralName)  -- Wrap the peripheral to access its methods
            
            -- Check if the methods exist
            if energyPeripheral.getEnergy and energyPeripheral.getEnergyCapacity then
                local displayText = displayEnergyInfo(energyPeripheral, lineOffset, monitorWidth)

                -- Save current bank information for the next comparison
                prevEnergyValue = previousTankInfo[peripheralName] and previousTankInfo[peripheralName].energy or 0
                if prevEnergyValue ~= energyPeripheral.getEnergy() then
                    isChanged = true
                end

                -- Store the energy value for future comparison
                previousTankInfo[peripheralName] = { energy = energyPeripheral.getEnergy() }

                -- Ensure the display text fits within monitor width
                if #displayText > monitorWidth then
                    displayText = displayText:sub(1, monitorWidth - 3) .. "..."  -- Truncate with ellipsis
                end

                -- Display on monitor
                if mon then
                    mon.setCursorPos(1, lineOffset)  -- Set cursor position for each bank info
                    mon.write(displayText)  -- Write the display text
                    lineOffset = lineOffset + 1  -- Move to the next line for the next bank
                end
            else
                print(string.format("Peripheral %s does not support required methods.", peripheralName))
            end
        else
            print(string.format("Peripheral %s is not recognized as an energy bank. Type: %s", peripheralName, peripheralType))
        end
    end

    -- Footer
    if mon then
        -- Move to lineOffset to write the footer
        mon.setCursorPos(1, lineOffset)  
        mon.write(string.rep("=", monitorWidth))  -- Adjust footer based on monitor width
        lineOffset = lineOffset + 1  -- Move to the next line for status indication

        -- Display current status indication
        local totalTanks = #tankData or 0
        local statusText = string.format("==========[%d/%d]==========", 1, totalTanks)

        -- Ensure footer text fits within monitor width
        if #statusText > monitorWidth then
            statusText = statusText:sub(1, monitorWidth - 3) .. "..."  -- Truncate with ellipsis
        end

        mon.setCursorPos(1, lineOffset)
        mon.write(statusText)  -- Write the final status on the monitor
    end

    -- If values have changed, broadcast the message
    if isChanged then
        local message = table.concat(formattedOutput, "\n")
        rednet.broadcast(message) -- Use a specific message header if desired
        print("Broadcasting bank information change:\n" .. message)
    end
end

-- Main loop to continually check bank information
while true do
    checkEnergyInfo()
    sleep(5) -- Wait for 5 seconds before checking again; adjust as needed
end