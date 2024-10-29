local scrapperSide = "bottom"
local scrapinator = peripheral.wrap(scrapperSide)
local items = nil

while true do
    local items = scrapinator.list()
    if items == nil then return end
    for k, v in pairs(items) do
        if v.name == "techreborn:scrap_box" then
        else
            print(v.name)
        end
    end
    sleep(0.001)
end