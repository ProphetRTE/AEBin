-- Require the aeprogress library
os.loadAPI("lib/aeprogress")
os.loadAPI("lib/aeprint")

-- Function to check if a peripheral has the required functions
local function hasRequiredFunctions(peripheralName)
    return peripheral.hasType(peripheralName, "tank") or peripheral.hasType(peripheralName, "fluid")
end

-- Function to calculate the percentage of a tank
local function calculatePercentage(tankSize, fluidAmount)
    if tankSize == 0 then
        return 0
    else
        return math.floor((fluidAmount / tankSize) * 100)
    end
end

-- Function to format the tank information
local function formatTank(peripheralName, tankName, tankSize, fluidAmount)
    local percentage = calculatePercentage(tankSize, fluidAmount)
    local bar = ""
    for i = 1, percentage do
        bar = bar .. "="
    end
    for i = 1, 100 - percentage do
        bar = bar .. "-"
    end
    
    return {
        name = peripheralName .. ": " .. tankName,
        size = tankSize,
        fullnessBar = bar,
        percentage = percentage
    }
end

-- Function to process the tank peripherals
local function processTank(peripheralName)
    local fluidPeripheral = peripheral.wrap(peripheralName)
    
    -- Check for the required functions
    if fluidPeripheral.pullFluid and fluidPeripheral.tanks and fluidPeripheral.pushFluid then
        local tanks = fluidPeripheral.tanks()
        local tankInfo = {}
        
        for _, tank in ipairs(tanks) do
            -- Assume each tank has a `getFluid` method that returns the amount of fluid (this can vary by mod)
            local fluidAmount = fluidPeripheral.getFluid(tank)
            local tankDetails = formatTank(peripheralName, tank, fluidPeripheral.getTankInfo(tank).capacity, fluidAmount)

            -- Store tank information for progress display
            actionTable = {}
            actionTable[1] = function()
                aeprint.aeprint(tankDetails.name .. "\n  Size: " .. tankDetails.size .. "mB\n  Fullness: " .. tankDetails.fullnessBar .. " (" .. tankDetails.percentage .. "%)\n", 0)
            end
            -- Add entries to this table as necessary.
        end
        
        -- Display progress
        aeprogress.aeprogress(actionTable, false)
    else
        aeprint.aeprint("Peripheral " .. peripheralName .. " does not support required functions.", 0)
    end
end

-- Initialize Rednet
rednet.open("top")  -- Change "top" to your connected side (e.g., "left", "right", etc.)

-- Get a list of all connected peripherals
local peripherals = peripheral.getNames()

-- Check each peripheral for required functions
for _, peripheralName in ipairs(peripherals) do
    if hasRequiredFunctions(peripheralName) then
        processTank(peripheralName)
    end
end

-- Close Rednet when done
rednet.close("top")