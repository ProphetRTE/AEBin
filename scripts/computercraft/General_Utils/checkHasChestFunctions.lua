-- Check for peripherals that have "chest" in their name
for _, name in ipairs(peripheral.getNames()) do
    if string.find(name, "chest") then  -- Check if the name contains "chest"
        local instance = peripheral.wrap(name)
        print("Checking peripheral: " .. name)
        print("  Type: " .. peripheral.getType(name))
        print("  Has getInventorySize method: " .. tostring(instance.getInventorySize ~= nil))
        print("  Has getItemDetail method: " .. tostring(instance.getItemDetail ~= nil))
    end
end