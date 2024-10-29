local scrapperSide = "bottom"
local scrapinator = peripheral.wrap(scrapperSide)
local items = nil

function SRItems()
    redstone.setOutput(scrapperSide, true)
    sleep(1)
    redstone.setOutput(scrapperSide, false)
end

while true do
    local items = scrapinator.list()
    if items == nil then
        SRItems()
        return
    end
    for k, v in pairs(items) do
        if v.name == "techreborn:scrap_box" then
        else
            local item = scrapinator.getItemDetail(2)
            print(item.displayName)
            SRItems()
        end
    end
end