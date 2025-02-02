local drain = peripheral.wrap("tconstruct:drain_0")

local previousTankInfo = {}

-- Used to process modem side arguments passed to functions.
function resolveModemSide(modemSide)
	-- If no modem side argument is provided, search for a modem and use that side.
  if modemSide == nil then
    for _,side in pairs(peripheral.getNames()) do
		if peripheral.getType(side) == "modem" then
			local modem = peripheral.wrap(side)
			if modem.isWireless() then
				modemSide = side
				break
			end
		end
    end
    if modemSide == nil then
      error("Could not find a modem.", 3)
    end
  else
		-- If an argument was provided, check that it is a valid side.
    local found = false
    for _,side in pairs(redstone.getSides()) do
      if side == modemSide then
        found = true
        break
      end
    end
    if not found then
      error(tostring(modemSide).." is not a valid side.", 3)
    end
  end
  if peripheral.getType(modemSide) ~= "modem" then
    error("No modem on side "..modemSide..".", 3)
  end

  log("Using modem "..modemSide..".")
  return modemSide
end

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
        rednet.broadcast(message) -- Use a specific message header if desired
        print("Broadcasting tank information change:\n" .. message)
    end
end

resolveModemSide(nil) -- Resolve modem side if not provided

-- Main loop to continually check tank information
while true do
    checkTankInfo()
    sleep(5) -- Wait for 5 seconds before checking again; adjust as needed
end