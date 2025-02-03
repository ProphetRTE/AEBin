local utils = require("lib/aeutils")

-- Valve, Monitor & Wireless Modem
local val = peripheral.wrap("tconstruct:drain_0")
local mon = peripheral.find("monitor")
local wmod = peripheral.wrap(utils.resolveModemSide())

local warning = 20       -- Warning level in %
local cap                -- Tank capacity
local amount             -- Amount liquid in tank
local percentfull        -- Percent liquid in tank
local lastpercent = 1000 -- Percent last loop
local sendmsg            -- Message to send
local sleeptime          -- How long to sleep
local sendFreq = 3       -- Modem Frequency
local content = "Water"  -- What is in tank?
-- Make sure frequency match the main computer

-- Set warning lamp to off
redstone.setOutput("right", false)

-- Main prog loop, never stop
while true do
  mon.clear()
  mon.setCursorPos(1,1)

  -- Fill table with data from tank valve
  tanksTable = val.getTanks("WhatIsThis")
  maintank = tanksTable[1]

  -- Get values for tank capacity and amount
  cap = maintank.capacity / 1000   -- in buckets
  amount = maintank.amount    -- in millibuckets
  
  -- If tank is empty, to avoid math issues with 0
  if amount == nil then
    amount = 0
    percentfull = 0
  else
    -- Use math.floor to convert to integers
    amount = math.floor(amount / 1000)
    percentfull = math.floor(100 * amount / cap)
  end

  -- Self explanatory :)
  mon.write(content)
  mon.setCursorPos(1,2)
  mon.write("Amount: " ..amount .."/"..cap .." B.")
  mon.setCursorPos(1,3)
  mon.write("Amount: " ..percentfull .."%  ")

  -- Check for change since last loop  
  if percentfull == lastpercent then
    print("Still " ..percentfull .. "%, nothing sent.")
  else
    -- If value changed, send to main!
    sendmsg = content ..": " ..percentfull .." %"
    --wmod.transmit(sendFreq,0,sendmsg)
    print("Sent: " ..sendmsg)
  end

  -- Save for next loop
  lastpercent = percentfull

  -- Warning control, local lamp
  mon.setCursorPos(1,5)
  
  if percentfull < warning then
    redstone.setOutput("right", true)
    mon.write("Less than " ..warning .."% full")
    sleep(1)
    redstone.setOutput("right", false)
    sleeptime = 1 
  else
    -- Above warning level, sleep longer
    mon.write("More than " ..warning .."% full")
    sleeptime = 10
  end

  -- Sleep either 1 or 10 seconds
  sleep(sleeptime)    
end