--This program will be a program to build bridges in the void
--Warning at present there are not going to be railings
--So if you want railing then you will have to build them yourself
--either make the bridge 2 blocks wider then you want so you can place the railings
--or use an existing wall to place blocks against
--Start Turtle 1 block back and on the left side of the bridge deck
args = {...}
width = args[2]
length = args[1]
blocks = width + length
neededfuel = 0

--Functions
function helpinfo()
    if args[1] == "help" then
        print("Please place turtle on the right most block of the bridge then the")
        print("Command format is")
        print("bridge length width")
    end
end
function digUp()
    while turtle.detectUp() == true do
		turtle.digUp()
	end
end
function dig()
    while turtle.detect() == true do
		turtle.dig()
	end
end
function digDown()
    while turtle.detectDown() == true do
		turtle.digDown()
	end
end
function forward()
    dig()
    turtle.forward()
    if turtle.detectUp() == true then
        turtle.digUp()
    end
end
function makefloor()
    if turtle.detectDown() == false then
        turtle.select(1)
        turtle.placeDown()
    end
end
function fuelcheck()
    if turtle.getFuelLevel() <= 100 then
		for j = 1,16,1 do
			turtle.select(j)
			turtle.refuel()
		end
	end
end

function deckrow()
    width = width - 1
    if turtle.getItemCount() <= 0 then
            slot = turtle.getSelectedSlot()
            slot = slot + 1
            turtle.select(slot)
    end
    turtle.placeDown()
    for x=1,width,1 do
        forward()
        if turtle.getItemCount() <= 0 then
            slot = turtle.getSelectedSlot()
            slot = slot + 1
            turtle.select(slot)
        end
        turtle.placeDown()
    end
    for x=1,width,1 do
        turtle.back()
    end
    width = width + 1
end
function inventorycheck()
    total = 0
    for i = 1, 16, 1 do
        turtle.select(i)
        total = total + turtle.getItemCount(i)
    end
    if total <= blocks then
        print("I will Need this many blocks:")
        print(blocks)
        error("Need Blocks")
    else
        print("Good on Blocks")
    end
    turtle.select(1)
end
function fuelusage()
    neededfuel = length
    neededfuel = neededfuel + width
    neededfuel = neededfuel + width
    neededfuel = neededfuel + 2
    if neededfuel >= turtle.getFuelLevel() then
        print("I will need this much Fuel")
        print(neededfuel)
        error("Need Fuel")
    else
        print("Good on Fuel")
    end
end
function nextrow()
    turtle.turnRight()
    forward()
    turtle.turnLeft()
end
function buidlbridge()
    length = length - 1
    forward()
    turtle.turnLeft()
    for i = 1,length,1 do
        deckrow()
        nextrow()
    end
    deckrow()
    turtle.turnRight()
    turtle.back()
    turtle.back()
    length = length + 1
end

--Start Of Program

helpinfo()
inventorycheck()
fuelusage()
buidlbridge()