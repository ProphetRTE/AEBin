-- Function to format and print the function names
local function printFunctions(peripheralName, functions)
    print("Peripheral: " .. peripheralName)
    print("Available Functions:")
    for _, funcName in ipairs(functions) do
        print(" - " .. funcName)
    end
    print("")  -- Blank line for spacing
end

-- Get the list of all connected peripherals
local peripherals = peripheral.getNames()

-- Check if there are any peripherals connected
if #peripherals == 0 then
    print("No peripherals connected.")
else
    -- Loop through each peripheral and display its functions
    for _, peripheralName in ipairs(peripherals) do
        -- Try to get the methods available on the peripheral
        local functions, err = pcall(peripheral.getMethods, peripheralName)
        
        if functions then
            printFunctions(peripheralName, peripheral.getMethods(peripheralName))
        else
            print("Could not retrieve functions for " .. peripheralName .. ": " .. err)
        end
    end
end