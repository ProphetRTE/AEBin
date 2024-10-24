-- Clock for display on a monitor
-- Author: CecilKilmer
-- Version: 1.0
-- Date: 2013/09/15

-- Min width required (IE: 10:00 PM)
minWidthReq = 8
minHeightReq = 2

-- Figure out where our monitor is
monitorSide = nil
monitor = nil

if peripheral.getType("left") == "monitor" then
	monitorSide = "left"
elseif peripheral.getType("right") == "monitor" then
	monitorSide = "right"
elseif peripheral.getType("top") == "monitor" then
	monitorSide = "top"
elseif peripheral.getType("bottom") == "monitor" then
	monitorSide = "bottom"
elseif peripheral.getType("front") == "monitor" then
	monitorSide = "front"
elseif peripheral.getType("back") == "monitor" then
	monitorSide = "back"
end

screenWidth = 0
screenHeight = 0

-- If we have one, redirect term to it
if monitorSide ~= nil then
	monitor = peripheral.wrap(monitorSide)
	term.redirect(monitor)
	
	local scale = 5.5
	
	repeat
		scale = scale - 0.5
		monitor.setTextScale(scale)
		screenWidth, screenHeight = term.getSize()
	until screenWidth > minWidthReq and screenHeight > minHeightReq
end

-- Determine our screen size
screenWidth, screenHeight = term.getSize()
yPos = screenHeight - minHeightReq
yPos = math.floor(yPos / 2)

-- Main loop
while true do
	term.clear()
	
	local time = os.time()
	time = textutils.formatTime(time, false)

	local xPos = screenWidth - string.len(time)
	xPos = math.ceil(xPos / 2)
	term.setCursorPos(xPos + 1, yPos + 2)
	print(time)
	
	sleep(.1)
end