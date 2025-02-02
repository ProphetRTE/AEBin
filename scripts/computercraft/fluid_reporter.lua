local drain = peripheral.wrap("tconstruct:drain_0")

local tankInfo = drain.tanks()

-- Function to format and print tank contents
local function formatTankInfo(tanks)
    if not tanks or #tanks == 0 then
        print("No tanks found.")
        return
    end
    
    for i, tank in ipairs(tanks) do
        if tank and tank.name and tank.amount then
            print(string.format("Tank %d: %s - Amount: %d", i, tank.name, tank.amount))
        else
            print(string.format("Tank %d: Empty or undefined", i))
        end
    end
end

-- Call the function to format and print the tank information
formatTankInfo(tankInfo)