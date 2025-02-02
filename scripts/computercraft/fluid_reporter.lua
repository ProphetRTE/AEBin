local drain = peripheral.wrap("tconstruct:drain_0")

local tank1, tank2 = unpack( drain.tanks() )
-- tank1 should be the molten contents and tank2 should be the smeltery fuel(lava usually i think...)

 print( "contents: ", textutils.serialize(tank1.contents) )