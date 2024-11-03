local connectionSide = "bottom"
local methods = peripheral.getMethods(connectionSide)
local converter = peripheral.wrap(connectionSide)
local objects = converter.getAvailableObjects()

-- Using a table to aggregate items
local aggregatedItems = {}

-- Aggregate duplicate items
for _, object in pairs(objects) do
    local displayName = object.displayName or "Unknown"
    local amount = object.amount or 0
    
    if aggregatedItems[displayName] then
        aggregatedItems[displayName].amount = aggregatedItems[displayName].amount + amount
    else
        aggregatedItems[displayName] = { displayName = displayName, amount = amount }
    end
end

local totalItems = #aggregatedItems
local itemsPerPage = 10
local currentPage = 1
local maxPages = math.ceil(totalItems / itemsPerPage)

local function displayItems()
    term.clear()
    term.setCursorPos(1, 1)
    print("METHODS:")
    for n, m in pairs(methods) do
        print("[" .. n .. "]: " .. m)
    end

    print("\nOBJECTS:")
    local startIdx = (currentPage - 1) * itemsPerPage + 1
    local endIdx = math.min(startIdx + itemsPerPage - 1, totalItems)

    local idx = 1
    for displayName, item in pairs(aggregatedItems) do
        if idx >= startIdx and idx <= endIdx then
            print(item.displayName .. ": " .. item.amount)
        end
        idx = idx + 1
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