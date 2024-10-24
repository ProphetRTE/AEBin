local basalt = require("Basalt")
local energy = require("energy")

local w, h = term.getSize()

local main = basalt.createFrame("mainFrame"):show()
local solarFrame = main:addFrame("solarFrame"):setPosition(1,2):setBackground(colors.black):setSize(w, h-1):show()
local storedFrame = main:addFrame("storedFrame"):setPosition(1,2):setBackground(colors.black):setSize(w, h-1):hide()
local settingsFrame = main:addFrame("settingsFrame"):setPosition(1,2):setBackground(colors.black):setSize(w, h-1):hide()

local stats = {
    solar = {
        total = 0,
        totalCap = energy.solar:getTotalCapacity(),
        peripheralAmount = energy.solar:getTotalPeripherals()
    },
    su = {
        total = 0,
        totalCap = energy.su:getTotalCapacity(),
        peripheralAmount = energy.su:getTotalPeripherals()
    }
}

local useWiredModem = settings.get("energymon.use_wired_modem")

local menuBar = main:addMenubar("mainMenuBar"):addItem("Solar"):addItem("Stored"):addItem("Settings"):setBackground(colors.gray):setSize(w, 1):setSpace(5):setScrollable():show()
menuBar:onChange(function(self)
    solarFrame:hide()
    storedFrame:hide()
    settingsFrame:hide()

    if self:getValue().text == "Solar" then
        solarFrame:show() 
    elseif self:getValue().text == "Stored" then
        storedFrame:show()
    elseif self:getValue().text == "Settings" then
        settingsFrame:show()
    end
end)

--#region Solar Frame

local currentStoredSolar = solarFrame:addLabel("currentStoredSolar"):setPosition(2,2):setForeground(colors.white):setText("Currently Stored Energy: " .. energy:toRadix(stats.solar.total)):show()
local maxStoredSolar = solarFrame:addLabel("maxStoredSolar"):setPosition(2,3):setForeground(colors.white):setText("Maximum Amount of Stored Energy: " .. energy:toRadix(stats.solar.totalCap)):show()
local attachedPeripherals_solarFrame = solarFrame:addLabel("attachedPeripherals"):setPosition(2,4):setForeground(colors.white):setText("Attached Solar Panels: " .. tostring(stats.solar.peripheralAmount)):show()
local broadcastInformation_solarFrame = solarFrame:addButton("broadcastInfo"):setPosition(2, 6):setSize(24,3):setBackground(colors.green):setForeground(colors.white):setText("Broadcast Information"):onClick(function (self)
    self:onClick(function(self) self:setBackground(colors.gray) self:setForeground(colors.white) end)
    self:onClickUp(function(self) self:setBackground(colors.green) self:setForeground(colors.white) end)
    self:onLoseFocus(function(self) self:setBackground(colors.green) self:setForeground(colors.white) end)

    local modems = {peripheral.find("modem", function(name, modem)
        return (useWiredModem and modem.isWireless == false) or modem.isWireless()
    end)}
    local modem = modems[1]

    if modem == nil then basalt.debug("No modem connected.") return end
    modem.transmit(65473, 0, stats.solar)
end)

--#endregion

--#region Stored Frame

local currentStoredEnergy = storedFrame:addLabel("currentStoredEnergy"):setPosition(2,2):setForeground(colors.white):setText("Currently Stored Energy: " .. energy:toRadix(stats.su.total)):show()
local maxStoredEnergy = storedFrame:addLabel("maxStoredEnergy"):setPosition(2,3):setForeground(colors.white):setText("Maximum Amount of Stored Energy: " .. energy:toRadix(stats.su.totalCap)):show()
local attachedPeripherals_storedFrame = storedFrame:addLabel("attachedPeripherals"):setPosition(2,4):setForeground(colors.white):setText("Attached Energy Banks: " .. tostring(stats.su.peripheralAmount)):show()
local broadcastInformation_storedFrame = storedFrame:addButton("broadcastInfo"):setPosition(2, 6):setSize(24,3):setBackground(colors.green):setForeground(colors.white):setText("Broadcast Information"):onClick(function (self)
    self:onClick(function(self) self:setBackground(colors.gray) self:setForeground(colors.white) end)
    self:onClickUp(function(self) self:setBackground(colors.green) self:setForeground(colors.white) end)
    self:onLoseFocus(function(self) self:setBackground(colors.green) self:setForeground(colors.white) end)

    local modems = {peripheral.find("modem", function(name, modem)
        return (useWiredModem and modem.isWireless == false) or modem.isWireless()
    end)}
    local modem = modems[1]

    if modem == nil then basalt.debug("No modem connected.") return end
    modem.transmit(65473, 0, stats.su)
end)

--#endregion

--#region Settings frame

local useWiredModemCheckbox = settingsFrame:addCheckbox("useWiredModem"):setPosition(2, 2):setForeground(colors.white):onChange(function(self)
    local checked = self:getValue()
    useWiredModem = checked

    settings.set("energymon.use_wired_modem", checked)
    basalt.debug("Set `use_wired_modem` to: " .. tostring(useWiredModem))
end):show()
useWiredModemCheckbox:setValue(useWiredModem)
local useWiredModemModemLabel = settingsFrame:addLabel("useWiredModemLabel"):setPosition(4, 2):setForeground(colors.white):setText("Use Wired modem"):show()
settingsFrame:addButton("refreshButton"):setPosition(2, 5):setText("Refresh"):setSize(15,3):setBackground(colors.green):setForeground(colors.white):onClick(function (self)
    self:onClick(function(self) self:setBackground(colors.gray) self:setForeground(colors.white) end)
    self:onClickUp(function(self) self:setBackground(colors.green) self:setForeground(colors.white) end)
    self:onLoseFocus(function(self) self:setBackground(colors.green) self:setForeground(colors.white) end)

    stats.solar.peripheralAmount = energy.solar:getTotalPeripherals()
    stats.su.peripheralAmount = energy.su:getTotalPeripherals()

    stats.solar.total = energy.solar:getTotalStored()
    stats.su.total = energy.su:getTotalStored()

    stats.solar.totalCap = energy.solar:getTotalCapacity()
    stats.su.totalCap = energy.su:getTotalCapacity()

    attachedPeripherals_solarFrame:setText("Attached Solar Panels: " .. tostring(stats.solar.peripheralAmount))
    attachedPeripherals_storedFrame:setText("Attached Energy Banks: " .. tostring(stats.su.peripheralAmount))

    currentStoredSolar:setText("Currently Stored Energy: " .. energy:toRadix(stats.solar.total))
    currentStoredEnergy:setText("Currently Stored Energy: " .. energy:toRadix(stats.su.total))

    maxStoredSolar:setText("Maximum Amount of Stored Energy: " .. energy:toRadix(stats.solar.totalCap))
    maxStoredEnergy:setText("Maximum Amount of Stored Energy: " .. energy:toRadix(stats.su.totalCap))

    basalt.debug("Refreshed peripherals and total capacity.")
end)

--#endregion

--#region Threads

local function checkSolarEnergy()
    stats.solar.total = energy.solar:getTotalStored()

    while true do
        stats.solar.total = energy.solar:getTotalStored()
        currentStoredSolar:setText("Currently Stored Energy: " .. energy:toRadix(stats.solar.total))

        os.sleep(1)
    end
end

local function checkStoredEnergy()
    while true do
        stats.su.total = energy.su:getTotalStored()
        currentStoredEnergy:setText("Currently Stored Energy: " .. energy:toRadix(stats.su.total))

        os.sleep(1)
    end
end

main:addThread("solarThread"):start(checkSolarEnergy)
main:addThread("storedThread"):start(checkStoredEnergy)

--#endregion

basalt.autoUpdate()