local scrapinator = peripheral.wrap("bottom")
local methods = peripheral.getMethods("bottom")
local isOn = redstone.getOutput()
local items = nil

function toggleOutput()
    isOn = not isOn
    redstone.setOutput("bottom", isOn)
end

while true do
    local items = scrapinator.list()
    toggleOutput()
    if items == nil return end
    for k, v in pairs(items) do
        if v.name ~= "techreborn:scrap_box" then
        else
            print(v.name)
        end
    end

    sleep(0.1)
    toggleOutput()
end