local w, h = term.getSize()
local entriesPerPage = 5
local totalEntries = 0
local currentPage = 1
local selectedEntry = 1

local menus = {}
local currentMenu = "main"
local running = true

function render()
    term.clear()
    term.setCursorPos(1, 1)

    local menu = menus[currentMenu] or menus["main"]
    totalEntries = #menu.entries

    -- Adjust selected entry based on current page
    local pageOffset = (currentPage - 1) * entriesPerPage
    local maxPages = math.ceil(totalEntries / entriesPerPage)

    if selectedEntry > entriesPerPage then
        selectedEntry = entriesPerPage
    elseif selectedEntry < 1 then
        selectedEntry = 1
    end

    if currentMenu ~= "main" then
        table.insert(menu.entries, {
            label = "[BACK]",
            callback = function()
                currentMenu = menu.parent or "main"
                selectedEntry = 1 -- reset selection when going back
                currentPage = 1 -- reset page when going back
                render()
            end
        })
    end

    -- Render menu entries for the current page
    for i = 1, entriesPerPage do
        local entryIndex = pageOffset + i
        if entryIndex > totalEntries then
            break
        end

        local caret = selectedEntry == i and ">> " or "   "
        term.setTextColor(selectedEntry == i and colors.magenta or colors.white)

        -- Center the text visually
        local entryLine = caret .. menu.entries[entryIndex].label
        local padded = string.format("%-" .. (w - 3) .. "s", entryLine)
        print(padded)
    end

    -- Page indicators
    term.setTextColor(colors.white)
    print(string.format("Page %d of %d", currentPage, maxPages))
end

function onKeyPress(key)
    local menu = menus[currentMenu] or menus["main"]

    local switch = (({
        [keys.enter] = menu.entries[(currentPage - 1) * entriesPerPage + selectedEntry].callback or function() end,

        [keys.up] = function()
            selectedEntry = selectedEntry - 1
            if selectedEntry < 1 then
                if currentPage > 1 then
                    currentPage = currentPage - 1
                    selectedEntry = entriesPerPage
                else
                    selectedEntry = 1
                end
            end
        end,

        [keys.down] = function()
            selectedEntry = selectedEntry + 1
            if selectedEntry > entriesPerPage then
                if currentPage < math.ceil(totalEntries / entriesPerPage) then
                    currentPage = currentPage + 1
                    selectedEntry = 1
                else
                    selectedEntry = entriesPerPage
                end
            end
        end
    })[key] or function() end)

    switch()

    if selectedEntry > entriesPerPage or selectedEntry <= 0 then
        selectedEntry = selectedEntry > entriesPerPage and entriesPerPage or 1
    end
end

function thread()
    while running do
        render()

        local event, key = os.pullEvent("key")
        onKeyPress(key)
    end
end

return {
    init = function(m) menus = m end,
    exit = function() running = false end,
    render = render,
    thread = thread
}