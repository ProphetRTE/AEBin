local running = true  -- Control variable to keep the loop running

-- Function to draw the GUI
function drawGUI(storageInfo)
    term.clear()
    term.setCursorPos(1, 1)
    print("Storage Overview:")
    print("----------------")
    
    -- Iterate through the storage devices and display their usage
    for name, info in pairs(storageInfo) do
        local percentUsed = (info.max > 0) and (info.used / info.max) * 100 or 0
        print(string.format("%s: %d/%d (%.2f%%)", name, info.used, info.max, percentUsed))
    end
    
    print("----------------")
    print("Press 'q' to quit.")
end

-- Coroutine function to handle user input for quitting the program
function inputHandler()
    while running do
        local event, param = os.pullEvent("key")
        if param == keys.q then
            print("Exiting program.")
            running = false -- Exit the loop and signal to stop the main loop
        end
    end
end

-- Function to gather storage info from a specified peripheral
function getStorageInfo(peripheral)
    local used = 0
    local max = 0
    local size = peripheral.getInventorySize()

    for slot = 1, size do
        local itemDetail = peripheral.getItemDetail(slot)  -- Get item details from the peripheral
        if itemDetail then
            used = used + itemDetail.count  -- Aggregate used space
            max = max + itemDetail.maxDamage or 0 -- Looks for maxDamage or sets to 0 if nil
        end
    end
    
    return used, max
end

-- Main function
local function main()
    -- Start the input handler coroutine
    coroutine.wrap(inputHandler)()

    while running do
        local storageInfo = {}

        -- Loop through all connected peripherals
        for _, name in ipairs(peripheral.getNames()) do
            if string.find(name, "chest") then  -- Check if the name contains "chest"
                local peripheralInstance = peripheral.wrap(name)

                -- Check if the peripheral supports inventory methods
                local hasInventoryMethods = peripheralInstance.getInventorySize and peripheralInstance.getItemDetail
                print(string.format("Checking peripheral: %s, supports inventory methods: %s", name, tostring(hasInventoryMethods)))

                if hasInventoryMethods then
                    local used, max = getStorageInfo(peripheralInstance)
                    storageInfo[name] = {used = used, max = max}
                    print(string.format("%s: used=%d, max=%d", name, used, max))  -- Debugging output
                end
            end
        end

        -- Draw the GUI with collected storage info
        drawGUI(storageInfo)

        sleep(1) -- Sleep to limit CPU usage
    end

    print("Exited")
end

-- Run the main function
main()