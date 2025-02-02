local drain = peripheral.wrap("tconstruct:drain_0")

local tankInfo = drain.tanks()

-- Function to separate modname and the actual name
local function formatName(name)
    -- Split by the colon and take the second part
    local modName, actualName = name:match("([^:]+):(.+)")
    
    -- If modName is not nil, format the actual name by splitting on underscores
    if actualName then
        local formattedName = actualName:gsub("_", " ") -- Replace underscores with spaces
        return string.format("%s (%s)", formattedName, modName)
    else
        return name -- Return the original name if no match
    end
end

-- Function to format and print tank contents
local function formatTankInfo(tanks)
    if not tanks or #tanks == 0 then
        print("No tanks found.")
        return
    end
    
    for i, tank in ipairs(tanks) do
        if tank and tank.name and tank.amount then
            local formattedName = formatName(tank.name)
            print(string.format("Tank %d: %s - Amount: %d", i, formattedName, tank.amount))
        else
            print(string.format("Tank %d: Empty or undefined", i))
        end
    end
end

-- Call the function to format and print the tank information
formatTankInfo(tankInfo)