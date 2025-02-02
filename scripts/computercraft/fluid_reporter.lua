local drain = peripheral.wrap("tconstruct:drain_0")

-- Rednet setup (you may need to specify the modem side)
local wirelessModem = peripheral.wrap("modem") -- Change this to the side your modem is connected to
if wirelessModem.isWireless() then
    wirelessModem.open(wirelessModem.getName())
end

local previousTankInfo = {}

-- Function to separate modname and the actual name
local function formatName(name)
    local modName, actualName = name:match("([^:]+):(.+)")
    if actualName then
        local formattedName = actualName:gsub("_", " ") -- Replace underscores with spaces
        return string.format("%s (%s)", formattedName, modName)
    else
        return name -- Return the original name if no match
    end
end

-- Function to format and check tank contents
local function checkTankInfo()
    local tankInfo = drain.tanks()

    if not tankInfo or #tankInfo == 0 then
        print("No tanks found.")
        return
    end

    local isChanged = false
    local formattedOutput = {}

    for i, tank in ipairs(tankInfo) do
        if tank and tank.name and tank.amount then
            local formattedName = formatName(tank.name)
            table.insert(formattedOutput, string.format("Tank %d: %s - Amount: %d", i, formattedName, tank.amount))

            -- Check for changes
            if previousTankInfo[i] and (previousTankInfo[i].amount ~= tank.amount) then
                isChanged = true
            end

            -- Save current tank information for next comparison
            previousTankInfo[i] = { name = tank.name, amount = tank.amount }
        else
            table.insert(formattedOutput, string.format("Tank %d: Empty or undefined", i))
            previousTankInfo[i] = nil -- Clear previous info if undefined
        end
    end

    -- If values have changed, broadcast the message
    if isChanged then
        local message = table.concat(formattedOutput, "\n")
        rednet.broadcast(message, "tankUpdate") -- Use a specific message header if desired
        print("Broadcasting tank information change:\n" .. message)
    end
end

-- Main loop to continually check tank information
while true do
    checkTankInfo()
    sleep(5) -- Wait for 5 seconds before checking again; adjust as needed
end