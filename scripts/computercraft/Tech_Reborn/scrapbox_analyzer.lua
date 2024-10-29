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
        local itemname = input:match(":(.*)$")
        if v.name == "techreborn:scrap_box" then
        else
            local itemname = v.name:match(":(.*)$")
            print(itemname)
            SRItems()
        end
    end
end