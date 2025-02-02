local drain = peripheral.wrap("tconstruct:drain_0")

-- This is very important! From my testing calling drain.getTankInfo("unknown") will not work!
-- We're going to find the side of the drain needed to get our info when calling getTankInfo and cache it.

local tankSide = (function()
      for _, direction in ipairs({'north', 'south', 'east', 'west'}) do
        local info = drain.getTankInfo(direction)
        if info and info[1] and info[1].contents then
          return direction -- we found the direction of the smeltery internal tanks relative to the drain...
          -- this is saved in var 'tankSide' for later calls to getTankInfo
        end
      end
    end)() -- this anonymous function is invoked immediately and returns the tankSide of interest

if not tankSide then error("Inner smeltery tanks couldn't be found! Is the smeltery drain attached??", 0) end

-- unpack will return all the elements in an indexed table or array in order. multiple assignment.
-- info = drain.getTankInfo(tankSide); tank1, tank2 = info[1], info[2], ... unpack works like so

local tank1, tank2 = unpack( drain.getTankInfo(tankSide) )
-- tank1 should be the molten contents and tank2 should be the smeltery fuel(lava usually i think...)

 print( "contents: ", textutils.serialize(tank1.contents) )