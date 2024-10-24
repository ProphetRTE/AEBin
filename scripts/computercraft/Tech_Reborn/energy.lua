local energy = {
    su = {
        battery_box = {name = "low_voltage_su"},
        mfe = {name = "medium_voltage_su"},
        mfsu = {name = "high_voltage_su"}
    }, 
    solar = {
        basic = {name = "basic_solar_panel"},
        advanced = {name = "advanced_solar_panel"},
        industrial = {name = "industrial_solar_panel"},
        ultimate = {name = "ultimate_solar_panel"},
        quantum = {name = "quantum_solar_panel"},
        creative = {name = "creative_solar_panel"}
    }, 
    generators = {
        diesel = {name = "diesel_generator"}, 
        gas = {name = "gas_turbine"}, 
        water = {name = "water_mill"}, 
        lightning = {name = "lightning_rod"},
        dragon_egg = {name = "dragon_egg_syphon"},
        plasma = {name = "plasma_generator"}
    }
}

--#region Helpers

function energy:getPeripheralsFromType(tType)
    local tPeripherals = {}

    if type(tType) == "table" then
        for _,v in pairs(tType) do
            for i, sPeriph in pairs(peripheral.getNames()) do
                if sPeriph:find(v) then
                    tPeripherals[i] = sPeriph
                end
            end
        end
    else
        for i, v in pairs(peripheral.getNames()) do
            if v:find(tType) then
                tPeripherals[i] = v
            end
        end
    end

    return tPeripherals
end

function energy:toRadix(energy)
    if energy > 1e6 then
        return tostring(energy / 1e6) .. " ME    "
    elseif energy > 1e3 then
        return tostring(energy / 1e3) .. " kE    "
    else 
        return tostring(energy) .. " E    "
    end
end

function energy:getTotalStoredFromType(tType)
    local iStored = 0

    if type(tType) == "table" then
        for _, v in pairs(tType) do
            local tPeripherals = energy:getPeripheralsFromType(v)

            for i, sPeriph in pairs(tPeripherals) do
                local wrap = peripheral.wrap(sPeriph)
                iStored = iStored + wrap.getEnergy()
            end
        end
    else
        local tPeripherals = energy:getPeripheralsFromType(tType)
    
        for i, sPeriph in pairs(tPeripherals) do
            local wrap = peripheral.wrap(sPeriph)
            iStored = iStored + wrap.getEnergy()
        end
    end

    return iStored
end

function energy:getTotalCapacityFromType(tType)
    local iCapacity = 0

    if type(tType) == "table" then
        for _, v in pairs(tType) do
            local tPeripherals = energy:getPeripheralsFromType(v)
            
            for i, sPeriph in pairs(tPeripherals) do
                local wrap = peripheral.wrap(sPeriph)
                iCapacity = iCapacity + wrap.getEnergyCapacity()
            end
        end
    else
        local tPeripherals = energy:getPeripheralsFromType(tType)
    
        for i, sPeriph in pairs(tPeripherals) do
            local wrap = peripheral.wrap(sPeriph)
            iCapacity = iCapacity + wrap.getEnergyCapacity()
        end
    
    end

    return iCapacity
end

function energy:getTableLength(tbl) 
    local iLength = 0

    for _, _ in pairs(tbl) do
        iLength = iLength + 1
    end

    return iLength
end

--#endregion

--#region SU (Battery Boxes and such)

function energy.su:getTotalStored()
    local tTypes = {"low_voltage_su", "medium_voltage_su", "high_voltage_su"}
    local tPeripherals = energy:getPeripheralsFromType(tTypes)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.su:getTotalCapacity()
    local tTypes = {"low_voltage_su", "medium_voltage_su", "high_voltage_su"}
    local tPeripherals = energy:getPeripheralsFromType(tTypes)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.su:getTotalPeripherals() 
    local tTypes = {"low_voltage_su", "medium_voltage_su", "high_voltage_su"}
    local tPeripherals = energy:getPeripheralsFromType(tTypes)
    local iTotal = energy:getTableLength(tPeripherals)

    return iTotal
end

function energy.su.battery_box:getTotalStored()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.su.mfe:getTotalStored() 
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.su.mfsu:getTotalStored() 
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.su.battery_box:getTotalCapacity() 
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.su.mfe:getTotalCapacity() 
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.su.mfsu:getTotalCapacity() 
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

--#endregion

--#region Solar Panels

function energy.solar:getTotalStored()
    local tTypes = {"basic_solar_panel", "advanced_solar_panel", "industrial_solar_panel", "ultimate_solar_panel", "quantum_solar_panel", "creative_solar_panel"}
    local tPeripherals = energy:getPeripheralsFromType(tTypes)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.solar:getTotalCapacity()
    local tTypes = {"basic_solar_panel", "advanced_solar_panel", "industrial_solar_panel", "ultimate_solar_panel", "quantum_solar_panel", "creative_solar_panel"}
    local tPeripherals = energy:getPeripheralsFromType(tTypes)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.solar:getTotalPeripherals() 
    local tTypes = {"basic_solar_panel", "advanced_solar_panel", "industrial_solar_panel", "ultimate_solar_panel", "quantum_solar_panel", "creative_solar_panel"}
    local tPeripherals = energy:getPeripheralsFromType(tTypes)
    local iTotal = energy:getTableLength(tPeripherals)

    return iTotal
end

function energy.solar.basic:getTotalStored() 
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.solar.advanced:getTotalStored()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.solar.industrial:getTotalStored()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored 
end

function energy.solar.ultimate:getTotalStored()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.solar.quantum:getTotalStored()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.solar.creative:getTotalStored()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end


function energy.solar.basic:getTotalCapacity()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.solar.advanced:getTotalCapacity()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.solar.industrial:getTotalCapacity()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.solar.ultimate:getTotalCapacity()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.solar.quantum:getTotalCapacity()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.solar.creative:getTotalCapacity() 
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

--#endregion

--#region Generators (Diesel, wind, etc)

function energy.generators:getTotalStored() 
    local tTypes = {"diesel_generator", "gas_turbine", "water_mill", "lightning_rod", "dragon_egg_syphon", "plasma_generator"}
    local tPeripherals = energy:getPeripheralsFromType(tTypes)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.generators:getTotalCapacity() 
    local tTypes = {"diesel_generator", "gas_turbine", "water_mill", "lightning_rod", "dragon_egg_syphon", "plasma_generator"}
    local tPeripherals = energy:getPeripheralsFromType(tTypes)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.generators:getTotalPeripherals() 
    local tTypes = {"diesel_generator", "gas_turbine", "water_mill", "lightning_rod", "dragon_egg_syphon", "plasma_generator"}
    local tPeripherals = energy:getPeripheralsFromType(tTypes)
    local iTotal = energy:getTableLength(tPeripherals)

    return iTotal
end

function energy.generators.diesel:getTotalStored()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored 
end

function energy.generators.gas:getTotalStored()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.generators.dragon_egg:getTotalStored()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.generators.water:getTotalStored()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.generators.plasma:getTotalStored()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end

function energy.generators.lightning:getTotalStored()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iStored = energy:getTotalStoredFromType(tPeripherals)

    return iStored
end


function energy.generators.diesel:getTotalCapacity()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.generators.gas:getTotalCapacity()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.generators.dragon_egg:getTotalCapacity()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.generators.water:getTotalCapacity() 
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.generators.plasma:getTotalCapacity()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end

function energy.generators.lightning:getTotalCapacity()
    local tPeripherals = energy:getPeripheralsFromType(self.name)
    local iCapacity = energy:getTotalCapacityFromType(tPeripherals)

    return iCapacity
end


--#endregion

return energy