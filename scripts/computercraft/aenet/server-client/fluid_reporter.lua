os.loadAPI("lib/aeutils")
os.loadAPI("lib/aeprint")
os.loadAPI("lib/aenet")

-- Valve, Monitor & Wireless Modem
local mon = peripheral.find("monitor")
local wmod = aeutils.resolveModemSide(nil)
local previousTankInfo = {}
local acceptedTankTypes = {
  "tank",                   -- Original tank type
  "enderstorage:ender_tank", -- Ender Tank type from your list
  "tconstruct:drain",
}

local formattedOutput = {}
local tankData = {} -- To store data for each tank
local sendFreq = 3  -- Modem Frequency
local content       -- What is in tank?
local sleeptime     -- How long to sleep
local tanksTable    -- Table to hold tank information
local socket        -- Socket for the server

-- Set warning lamp to off
redstone.setOutput("right", false)

if not wmod then
  aeprint.aeprint("No modem found!")
  sleep(1)
else
  -- Set modem frequency
  aeprint.aeprint("Modem found, frequency set to " .. sendFreq)
end

function onStart()
    -- Connect to the server
    socket = aenet.connect("LoginDemoServer")
    -- Log in with a username and password
    aenet.login(socket, "Bobby", "mypass123")
    checkTankInfo()
    retrieveAvailableCommands(socket)
    sleep(5) -- Wait for 5 seconds before checking again; adjust as needed
end

-- Function to retrieve available commands or applications from the server
function retrieveAvailableCommands(socket)
    print("Retrieving available commands from the server...")
    aenet.send(socket, "get_commands") -- Assuming a "get_commands" command is defined on the server
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
function checkTankInfo()
  local peripherals = aeutils.getPeripherals()
  
  if #peripherals == 0 then
    aeprint.aeprint("No peripherals found.")
      if mon then
          mon.clear()
          mon.write("No peripherals found.")
      end
      return
  end

  local isChanged = false
  formattedOutput = {}

  -- Clear the monitor
  if mon then
      mon.clear()
      mon.setCursorPos(1, 1)
  end

  -- Get monitor width for formatting
  local monitorWidth = mon.getSize()  -- Get the monitor width

  -- Header
  if mon then
      mon.setCursorPos(1, 1)
      mon.write(string.rep("=", monitorWidth))  -- Adjust header based on monitor width
  end

  local lineOffset = 2  -- Starting line for tank information display

  -- Iterate through each peripheral to get tank info
  for _, peripheralName in pairs(peripherals) do
      local peripheralType = aeutils.getPeripheralType(peripheralName)

      -- Check if the peripheral type is in the accepted list
      if isAcceptedTankType(peripheralType) then
          local tankPeripheral = peripheral.wrap(peripheralName)  -- Wrap the peripheral to access its methods
          local tankInfo = tankPeripheral.tanks()  -- Adjust method name if needed
          tankData[peripheralName] = tankInfo
          
          for i, tank in ipairs(tankInfo) do
              local displayText
              if tank and tank.name and tank.amount then
                  local formattedName = aeutils.formatName(tank.name)
                  local amountInBuckets = tank.amount / 1000  -- Convert amount to buckets
                  displayText = string.format("[%d] %s - %dmB", i, formattedName, tank.amount)
                  table.insert(formattedOutput, displayText)  -- Add the display text to the formatted output for broadcasting
              else
                  displayText = string.format("[%d] Empty", i)
                  table.insert(formattedOutput, displayText)  -- Add empty text as well 
              end

              -- Ensure the display text fits within monitor width
              if #displayText > monitorWidth then
                  displayText = displayText:sub(1, monitorWidth - 3) .. "..."  -- Truncate with ellipsis
              end

              -- Display on monitor
              if mon then
                  mon.setCursorPos(1, lineOffset)  -- Set cursor position for each tank info
                  mon.write(displayText)  -- Write the display text
                  lineOffset = lineOffset + 1  -- Move to the next line for the next tank
              end

              -- Check for changes
              if previousTankInfo[i] and (previousTankInfo[i].amount ~= tank.amount) then
                  isChanged = true
              end

              -- Save current tank information for the next comparison
              previousTankInfo[i] = { name = tank.name, amount = tank.amount }
          end
      end
  end

  -- Footer
  if mon then
      -- Move to lineOffset to write the footer
      mon.setCursorPos(1, lineOffset)  
      mon.write(string.rep("=", monitorWidth))  -- Adjust footer based on monitor width
      lineOffset = lineOffset + 1  -- Move to the next line for status indication

      -- Display current status indication, ensuring it fits in width
      local totalTanks = #tankData or 0
      local statusText = string.format("==========[1/%d]==========", totalTanks)

      -- Ensure footer text fits within monitor width
      if #statusText > monitorWidth then
          statusText = statusText:sub(1, monitorWidth - 3) .. "..."  -- Truncate with ellipsis
      end

      mon.setCursorPos(1, lineOffset)
      mon.write(statusText)  -- Write the final status on the monitor
  end

  -- If values have changed, broadcast the message
  if isChanged then
    local message = table.concat(formattedOutput, "\n")
    aenet.send(socket, message) -- Use a specific message header if desired
    print("Broadcasting tank information change:\n" .. message)
  end
end

-- Function to send messages or commands to the server
function handleCommands(socket)
    while true do
        write("Enter command to send (or 'exit' to quit): ")
        local command = read()

        if command == "exit" then
            print("Exiting...")
            break
        end

        -- Send the command to the server
        aenet.send(socket, command)

        
        checkTankInfo()
    end
end

function onEvent(event)
    -- Logged in successfully
    if event[1] == "login" then
        -- The username logged in
        local username = event[2]
        -- The socket that was logged in
        local socket = event[3]
        print("Logged in as " .. username)
        aenet.send(socket, "Hello server!")

        handleCommands(socket)
        
    -- Login failed (wrong username or password)
    elseif event[1] == "login_failed" then
        print("Didn't manage to log in. :(")
        
    -- Received available commands from the server
    elseif event[1] == "available_commands" then
        print("Available commands:")
        for _, cmd in ipairs(event[2]) do
            print("- " .. cmd)
        end

    -- Respond to server commands
    elseif event[1] == "command_response" then
        print("Server response: " .. event[2])
        
    elseif event[1] == "encrypted_message" then
        print("Server said: " .. event[2])
    end
end

  
  aenet.startEventLoop(onStart, onEvent)