os.loadAPI("lib/aeutils")

-- Valve, Monitor & Wireless Modem
local val = peripheral.wrap("tconstruct:drain_0")
local mon = peripheral.find("monitor")
local wmod = aeutils.resolveModemSide(nil)

local tankData = {} -- To store data for each tank
local sendFreq = 3  -- Modem Frequency
local content       -- What is in tank?
local sleeptime     -- How long to sleep
local tanksTable    -- Table to hold tank information

-- Set warning lamp to off
redstone.setOutput("right", false)

if not modemSide then
  print("No modem found!")
  sleep(1)
else
  -- Set modem frequency
  wmod.open(sendFreq)
  print("Modem found, frequency set to " .. sendFreq)
end

-- Main prog loop, never stop
while true do
  mon.clear()
  mon.setCursorPos(1, 1)
  
  -- Fill table with data from tank valve
  tanksTable = val.tanks()

  -- Check if tanks are available
  if #tanksTable == 0 then
    mon.write("No tanks found!")
    sleep(1)
    goto continue -- Skip the rest of the loop and go to the next iteration
  end

  -- Iterate through each tank
  for i, tank in ipairs(tanksTable) do
    local cap = tank.amount / 1000   -- Capacity in buckets
    local amount = tank.amount        -- Amount in millibuckets
    local tankContent = aeutils.formatName(tank.name) -- What is in tank?
    
    -- If tank amount is nil, prevent division errors
    if amount == nil then
      amount = 0
    else
      -- Use math.floor to convert to integers
      amount = math.floor(amount / 1000)
    end

    -- Check for change and store the last amount for comparison
    local lastAmount = tankData[i] and tankData[i].lastAmount or 0
    tankData[i] = tankData[i] or {}
    tankData[i].lastAmount = amount

    -- Display tank information
    mon.setCursorPos(1, i)
    mon.write(tankContent)
    mon.setCursorPos(1, i + 1)
    mon.write("Amount: " .. amount .. "/" .. cap .. " B.")

    -- Check for change since the last loop  
    if amount ~= lastAmount then
      -- If the value changed, send to main
      local sendmsg = tankContent .. ": " .. amount .. " B"
      rednet.broadcast(sendmsg)
      print("Sent: " .. sendmsg)
    else
      print("Still " .. amount .. " B for " .. tankContent .. ", nothing sent.")
    end

    -- Warning control, local lamp
    if amount < 20 then  -- Warning level set at 20 B for example
      redstone.setOutput("right", true)
      mon.setCursorPos(1, 5)
      mon.write("Less than 20 B full")
      sleep(1)
      redstone.setOutput("right", false)
    else
      -- Display more than warning level message
      mon.setCursorPos(1, 5)
      mon.write("More than 20 B full")
    end
  end

  -- Sleep duration logic can be adjusted if needed
  sleeptime = 10 -- Default sleep time
  print("Sleeping for " .. sleeptime .. " seconds.")
  sleep(sleeptime)

  ::continue::
end