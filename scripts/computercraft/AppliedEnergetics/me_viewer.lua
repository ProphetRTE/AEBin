local connectionSide = "bottom"
local converter = peripheral.wrap(connectionSide)
local objects = converter.getAvailableObjects()

local totalItems = #objects
local itemsPerPage = 10
local currentPage = 1
local maxPages = math.ceil(totalItems / itemsPerPage)

local function displayItems()
    term.clear()
    term.setCursorPos(1, 1)

    print("\nOBJECTS:")
    local startIdx = (currentPage - 1) * itemsPerPage + 1
    local endIdx = math.min(startIdx + itemsPerPage - 1, totalItems)

    for i = startIdx, endIdx do
        local object = objects[i]
        local displayName = object.displayName or "Unknown"
        local amount = object.amount or 0
        print(displayName .. ": " .. amount)
    end

    print("\nPage " .. currentPage .. " of " .. maxPages)
    print("Scroll up and down to navigate.")
end

displayItems()

while true do
    local event, dir, x, y = os.pullEvent("mouse_scroll")
    
    if dir == -1 and currentPage < maxPages then
        currentPage = currentPage + 1  -- Scroll down
    elseif dir == 1 and currentPage > 1 then
        currentPage = currentPage - 1  -- Scroll up
    end
    
    displayItems()
end