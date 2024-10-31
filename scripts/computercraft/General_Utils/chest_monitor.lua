local chestSide = "bottom"  -- Replace with the side where your chest is connected
local chest = peripheral.wrap(chestSide)
local running = true         -- Control variable to keep the loop running

-- Function to draw the GUI
function drawGUI(items)
    term.clear()
    term.setCursorPos(1, 1)
    print("Items in Chest:")
    print("----------------")
    
    -- Iterate through the items and display their names and counts
    for _, item in pairs(items) do
        print(item.displayName .. " x" .. item.count)
    end
    
    print("----------------")
    print("Press 'q' to quit.")
end

-- Coroutine function to handle user input for quitting the program
function inputHandler()
    while running do
        local event, param = os.pullEvent("key")
        if param == keys.q then
            print("Exiting program.")
            running = false -- Exit the loop and signal to stop the main loop
        end
    end
end

-- Start the input handler coroutine
coroutine.wrap(inputHandler)()

-- Main loop
while running do
    local items = chest.list()
    local displayItems = {}  -- Prepare a table to store item info for display

    for _, v in pairs(items) do
        if v then  -- Ensure the item exists
            local itemDetail = chest.getItemDetail(v.slot)  -- Get item details from the chest
            if itemDetail then 
                local found = false
                
                -- Check if the item is already in the display list
                for i, item in ipairs(displayItems) do
                    if item.displayName == itemDetail.displayName then
                        item.count = item.count + v.count  -- Increment the count
                        found = true
                        break
                    end
                end

                -- If the item was not found in the display list, add it
                if not found then
                    table.insert(displayItems, {displayName = itemDetail.displayName, count = v.count})  -- Store item name and count
                end
            end
        end
    end
    
    drawGUI(displayItems) -- Draw the GUI showing items and their counts
    sleep(1) -- Sleep for a short duration to prevent excessive CPU usage
end

print("Exited")