local scrapperSide = "bottom"
local scrapinator = peripheral.wrap(scrapperSide)
local displayedItems = {}  -- To store item names for the GUI
local startIdx = 1         -- To track where we start displaying items
local maxDisplay = 10      -- Maximum number of items to display at once
local running = true        -- To control the running status of the program

function SRItems()
    redstone.setOutput(scrapperSide, true)
    sleep(1)
    redstone.setOutput(scrapperSide, false)
end

-- Function to draw the GUI
function drawGUI()
    term.clear()
    term.setCursorPos(1, 1)
    print("Scrap Items:")
    print("-------------")
    
    -- Draw the current set of displayed items
    for i = startIdx, math.min(startIdx + maxDisplay - 1, #displayedItems) do
        print(displayedItems[i])
    end
    
    print("-------------")
    print("Scroll with 'up'/'down', 'q' to quit.")
end

-- Coroutine function to handle user input for scrolling
function inputHandler()
    while running do
        local event, param = os.pullEvent("key")
        if param == keys.up then
            if startIdx > 1 then
                startIdx = startIdx - 1
            end
        elseif param == keys.down then
            if startIdx < #displayedItems - maxDisplay + 1 then
                startIdx = startIdx + 1
            end
        elseif param == keys.q then
            print("Exiting program.")
            running = false -- Exit the loop and signal to stop the main loop
        end
    end
end

-- Start the input handler coroutine
coroutine.wrap(inputHandler)()

-- Main loop
while running do
    local items = scrapinator.list()
    if items == nil then
        SRItems()
        return
    end

    for k, v in pairs(items) do
        if v.name ~= "techreborn:scrap_box" then
            local item = scrapinator.getItemDetail(k) -- Use item index instead of a hardcoded value (2)
            if item then -- Ensure item exists before attempting to access it
                table.insert(displayedItems, item.displayName)
                SRItems()
            end
        end
    end
    
    drawGUI() -- Draw the GUI after collecting items
end

print("Exited")