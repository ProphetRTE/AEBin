local scrapinator = peripheral.wrap("bottom")
local methods = peripheral.getMethods("bottom")
local items = nil

function toggleOutput()
    redstone.setOutput("bottom", true)
    sleep(0.1)
    redstone.setOutput("bottom", false)
end

while true do
    local items = scrapinator.list()
    if items == nil then return end
    for k, v in pairs(items) do
        if v.name == "techreborn:scrap_box" then
        else
            print(v.name)
        end
    end
    toggleOutput()
    sleep(0.20)
end