-- Function to check if a peripheral has storage methods
local function isStoragePeripheral(peripheral)
    return peripheral.getInventorySize ~= nil and peripheral.getInventorySize() > 0
end

-- Function to calculate the used and max storage of a peripheral
local function getStorageInfo(peripheral)
    local used = 0
    local max = 0
    
    for slot = 1, peripheral.getInventorySize() do
        local item = peripheral.getItemDetail(slot)
        if item then
            used = used + item.count
        end
    end
    
    max = peripheral.getInventorySize()

    return used, max
end

-- Main function
local function main()
    local totalUsed = 0
    local totalMax = 0

    -- Loop through all connected peripherals
    for _, name in ipairs(peripheral.getNames()) do
        local peripheralType = peripheral.getType(name)
        local peripheralInstance = peripheral.wrap(name)

        if isStoragePeripheral(peripheralInstance) then
            local used, max = getStorageInfo(peripheralInstance)
            totalUsed = totalUsed + used
            totalMax = totalMax + max
            print(string.format("%s: %d/%d %.2f%%", name, used, max, (used / max) * 100))
        end
    end

    if totalMax > 0 then
        print(string.format("Total: %d/%d %.2f%%", totalUsed, totalMax, (totalUsed / totalMax) * 100))
    else
        print("No valid storage peripherals found.")
    end
end

-- Run the main function
main()