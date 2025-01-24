for _, name in ipairs(peripheral.getNames()) do
    print("Peripheral Name: " .. name .. " Type: " .. peripheral.getType(name))
end