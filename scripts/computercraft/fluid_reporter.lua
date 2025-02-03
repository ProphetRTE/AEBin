os.loadAPI("lib/aeutils")

-- Valve, Monitor & Wireless Modem
local mon = peripheral.find("monitor")
local wmod = aeutils.resolveModemSide(nil)
local previousTankInfo = {}
local acceptedTankTypes = {
  "tank",                   -- Original tank type
  "enderstorage:ender_tank", -- Ender Tank type from your list
}
local tankData = {} -- To store data for each tank
local sendFreq = 3  -- Modem Frequency
local content       -- What is in tank?
local sleeptime     -- How long to sleep
local tanksTable    -- Table to hold tank information

-- Set warning lamp to off
redstone.setOutput("right", false)

if not wmod then
  print("No modem found!")
  sleep(1)
else
  -- Set modem frequency
  rednet.open(wmod)
  print("Modem found, frequency set to " .. sendFreq)
end

-- Function to check if the peripheral type is accepted
local function isAcceptedTankType(type)
  for _, acceptedType in ipairs(acceptedTankTypes) do
      if type == acceptedType then
          return true
      end
  end
  return false
end

-- Main function to check tank information
local function checkTankInfo()
  local peripherals = aeutils.getPeripherals()

  if #peripherals == 0 then
      print("No peripherals found.")
      if mon then
          mon.clear()
          mon.write("No peripherals found.")
      end
      return
  end

  local isChanged = false
  local formattedOutput = {}

  -- Clear the monitor
  if mon then
      mon.clear()
      mon.setCursorPos(1, 1)
  end

  -- Iterate through each peripheral to get tank info
  for _, peripheralName in pairs(peripherals) do
      local peripheralType = aeutils.getPeripheralType(peripheralName)
      --print(string.format("Checking peripheral: %s, Type: %s", peripheralName, peripheralType)) -- Debug log

      -- Check if the peripheral type is in the accepted list
      if isAcceptedTankType(peripheralType) then
          local tankPeripheral = peripheral.wrap(peripheralName)  -- Wrap the peripheral to access its methods
          local tankInfo = tankPeripheral.getTanks()  -- Adjust method name if needed

          for i, tank in ipairs(tankInfo) do
              if tank and tank.name and tank.amount then
                  local formattedName = aeutils.formatName(tank.name)
                  local amountInBuckets = tank.amount / 1000  -- Convert amount to buckets
                  table.insert(formattedOutput, string.format("Tank %d: %s - Amount: %d B / %.2f B", i, formattedName, tank.amount, amountInBuckets))

                  -- Display on monitor
                  if mon then
                      mon.setCursorPos(1, i)
                      mon.write(string.format("Tank %d: %s - %d B\n", i, formattedName, tank.amount))
                  end

                  -- Check for changes
                  if previousTankInfo[i] and (previousTankInfo[i].amount ~= tank.amount) then
                      isChanged = true
                  end

                  -- Save current tank information for the next comparison
                  previousTankInfo[i] = { name = tank.name, amount = tank.amount }
              else
                  table.insert(formattedOutput, string.format("Tank %d: Empty or undefined", i))
                  if mon then
                      mon.setCursorPos(1, i)
                      mon.write(string.format("Tank %d: Empty", i))
                  end
                  previousTankInfo[i] = nil -- Clear previous info if undefined
              end
          end
      else
          --print(string.format("Peripheral %s is not recognized as a tank. Type: %s", peripheralName, peripheralType))
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