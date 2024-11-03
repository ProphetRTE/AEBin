local connectionSide = "bottom"
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

-- Convert aggregatedItems to a sortable array
local itemList = {}
for _, item in pairs(aggregatedItems) do
    table.insert(itemList, item)
end

local function sortByName(a, b)
    return a.displayName < b.displayName
end

local function sortByAmount(a, b)
    return a.amount > b.amount
end

local currentSort = "name"  -- current sorting method
local function sortItems()
    if currentSort == "name" then
        table.sort(itemList, sortByName)
    elseif currentSort == "amount" then
        table.sort(itemList, sortByAmount)
    end
end

-- Initial sort
sortItems()

local itemsPerPage = 10
local currentPage = 1

local function displayItems()
    term.clear()
    term.setCursorPos(1, 1)

    print("\n======[" .. currentSort .. "]======")
    local totalItems = #itemList
    local maxPages = math.ceil(totalItems / itemsPerPage)

    local startIdx = (currentPage - 1) * itemsPerPage + 1
    local endIdx = math.min(startIdx + itemsPerPage - 1, totalItems)

    for idx = startIdx, endIdx do
        if itemList[idx] then
            print(itemList[idx].displayName .. "x" .. itemList[idx].amount)
        end
    end
    print("\n======[" .. currentPage .. "/" maxPages .. "]======")
    print("Scroll up and down to navigate.")
    print("Press 'N' to sort by name, 'A' to sort by amount.")
end

displayItems()

while true do
    local event, param = os.pullEvent()

    if event == "mouse_scroll" then
        if param == -1 and currentPage * itemsPerPage < #itemList then
            currentPage = currentPage + 1  -- Scroll down
        elseif param == 1 and currentPage > 1 then
            currentPage = currentPage - 1  -- Scroll up
        end
    elseif event == "key" then
        if param == keys.n then
            currentSort = "name"
            sortItems()
            currentPage = 1  -- Reset to the first page
            displayItems()
        elseif param == keys.a then
            currentSort = "amount"
            sortItems()
            currentPage = 1  -- Reset to the first page
            displayItems()
        end
    end

    displayItems()
end