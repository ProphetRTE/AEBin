-- Save this as startup.lua on the server computer with a modem attached to the computer. You can also optionally attach a drive to be able to create and erase ID cards.
local addIDPassword = "" -- Set this to a password that can be used to create a new ID card.
local secret = "" -- Set this to a randomly-generated secret code. This code should be copied to the secret variable for all clients.

if not addIDPassword or not secret or addIDPassword == "" or secret == "" then error("Please set some keys inside the script before running.") end

if not fs.exists("ids.lua") then
    local file = fs.open("ids.lua", "w")
    file.write("return {}")
    file.close()
end

local ok, err = pcall(function()
os.pullEvent = os.pullEventRaw
settings.set("shell.allow_disk_startup", false)
settings.save(".settings")

local sha256

do
    local MOD = 2^32

    local function rrotate(x, disp)
        x = x % MOD
        disp = disp % 32
        local low = bit32.band(x, 2 ^ disp - 1)
        return bit32.rshift(x, disp) + bit32.lshift(low, 32 - disp)
    end

    local k = {
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
        0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
        0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
        0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
        0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
        0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
        0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
        0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
        0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    }

    local function str2hexa(s)
        return (string.gsub(s, ".", function(c) return string.format("%02x", string.byte(c)) end))
    end

    local function num2s(l, n)
        local s = ""
        for i = 1, n do
            local rem = l % 256
            s = string.char(rem) .. s
            l = (l - rem) / 256
        end
        return s
    end

    local function s232num(s, i)
        local n = 0
        for i = i, i + 3 do n = n*256 + string.byte(s, i) end
        return n
    end

    local function preproc(msg, len)
        local extra = 64 - ((len + 9) % 64)
        len = num2s(8 * len, 8)
        msg = msg .. "\128" .. string.rep("\0", extra) .. len
        assert(#msg % 64 == 0)
        return msg
    end

    local function initH256(H)
        H[1] = 0x6a09e667
        H[2] = 0xbb67ae85
        H[3] = 0x3c6ef372
        H[4] = 0xa54ff53a
        H[5] = 0x510e527f
        H[6] = 0x9b05688c
        H[7] = 0x1f83d9ab
        H[8] = 0x5be0cd19
        return H
    end

    local function digestblock(msg, i, H)
        local w = {}
        for j = 1, 16 do w[j] = s232num(msg, i + (j - 1)*4) end
        for j = 17, 64 do
            local v = w[j - 15]
            local s0 = bit32.bxor(rrotate(v, 7), rrotate(v, 18), bit32.rshift(v, 3))
            v = w[j - 2]
            w[j] = w[j - 16] + s0 + w[j - 7] + bit32.bxor(rrotate(v, 17), rrotate(v, 19), bit32.rshift(v, 10))
        end

        local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
        for j = 1, 64 do
            local s0 = bit32.bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
            local maj = bit32.bxor(bit32.band(a, b), bit32.band(a, c), bit32.band(b, c))
            local t2 = s0 + maj
            local s1 = bit32.bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
            local ch = bit32.bxor(bit32.band(e, f), bit32.band(bit32.bnot(e), g))
            local t1 = h + s1 + ch + k[j] + w[j]
            h, g, f, e, d, c, b, a = g, f, e, d + t1, c, b, a, t1 + t2
        end

        H[1] = bit32.band(H[1] + a)
        H[2] = bit32.band(H[2] + b)
        H[3] = bit32.band(H[3] + c)
        H[4] = bit32.band(H[4] + d)
        H[5] = bit32.band(H[5] + e)
        H[6] = bit32.band(H[6] + f)
        H[7] = bit32.band(H[7] + g)
        H[8] = bit32.band(H[8] + h)
    end

    function sha256(msg)
        msg = preproc(msg, #msg)
        local H = initH256({})
        for i = 1, #msg, 64 do digestblock(msg, i, H) end
        return str2hexa(num2s(H[1], 4) .. num2s(H[2], 4) .. num2s(H[3], 4) .. num2s(H[4], 4) ..
            num2s(H[5], 4) .. num2s(H[6], 4) .. num2s(H[7], 4) .. num2s(H[8], 4))
    end
end

local modem = peripheral.find("modem")
modem.open(74)

parallel.waitForAll(function()
    while true do
        local ev, side, port, reply, message = os.pullEvent("modem_message")
        if port == 74 and type(message) == "string" and message:match("^%?%d*:") then
            local level = tonumber(message:match("^%?(%d*):")) or 0
            message = message:gsub("^%?%d+:", "?:")
            local found = false
            local ids = dofile("ids.lua")
            local toDelete = {}  -- Temporary table to hold IDs for deletion
            modem.open(reply)

            for i = #ids, 1, -1 do  -- Iterate in reverse
                local id = ids[i]

                -- Check if the ID is valid
                if (id.expiration == 0 or id.expiration > os.epoch("utc")) and (id.uses ~= 0) and (id.level >= level) then
                    if message == "?:" .. sha256("?:" .. id.id .. tostring(math.floor(os.epoch("utc") / 1000)) .. secret) or
                       message == "?:" .. sha256("?:" .. id.id .. tostring(math.floor(os.epoch("utc") / 1000) - 1) .. secret) then

                        found = true
                        modem.transmit(reply, 74, "=:" .. sha256("=:" .. id.id .. tostring(math.floor(os.epoch("utc") / 1000)) .. secret .. "true"))
                        if id.uses > 0 then
                            ids[i].uses = id.uses - 1
                        end
                        break  -- Exit loop after finding valid ID
                    end
                else
                    -- Mark the ID for deletion if it's expired
                    table.insert(toDelete, i)
                end
            end

            -- Delete all expired IDs at once after the validation check
            for j = #toDelete, 1, -1 do
                table.remove(ids, toDelete[j])
            end

            if not found then 
                modem.transmit(reply, 74, "=:" .. sha256("=:" .. message:sub(3) .. secret .. "false")) 
            end

            if reply ~= 74 then modem.close(reply) end

            -- Save the updated list of IDs after processing
            local file = fs.open("ids.lua", "w")
            file.write("return " .. textutils.serialize(ids))
            file.close()
        end
    end
end, function()
    while true do
        local w, h = term.getSize()
        term.clear()
        term.setCursorPos(w / 2 - 10, h / 2)
        term.write("Enter admin password:")
        term.setCursorPos(w / 2 - 10, h / 2 + 1)
        local pass = read("\7")
        if pass == addIDPassword then
            while true do
                term.clear()
                term.setCursorPos(w / 2 - 8, h / 2 - 2)
                term.write("Select an option:")
                term.setCursorPos(w / 2 - 8, h / 2 - 1)
                term.write("1. Add PIN")
                term.setCursorPos(w / 2 - 8, h / 2)
                term.write("2. Remove PIN")
                term.setCursorPos(w / 2 - 8, h / 2 + 1)
                term.write("3. Modify PIN")
                term.setCursorPos(w / 2 - 8, h / 2 + 2)
                term.write("4. List PINs")
                term.setCursorPos(w / 2 - 8, h / 2 + 3)
                term.write("5. Exit")
                local ev, num = os.pullEvent("char")
                if num == "2" then
                    term.clear()
                    term.setCursorPos(w / 2 - 5, h / 2 - 1)
                    print("Enter PIN:")
                    term.setCursorPos(w / 2 - 5, h / 2)
                    local idToRemove = read("\7")  -- Get the PIN from user input
                    local ids = dofile("ids.lua")
                    
                    local validCount = 0  -- Count of valid entries
                    local pinRemoved = false  -- Flag to check if a PIN was removed
                
                    -- Count valid IDs
                    for _, v in ipairs(ids) do
                        if (v.expiration == 0 or v.expiration > os.epoch("utc")) and (v.uses > 0 or v.uses == -1) then
                            validCount = validCount + 1
                        end
                    end
                
                    -- Remove the specified PIN if valid count is greater than 1
                    for i = #ids, 1, -1 do
                        if ids[i].id == idToRemove then
                            if validCount > 1 then
                                table.remove(ids, i)  -- Use table.remove for proper removal
                                pinRemoved = true  -- Set flag to true
                                break  -- Exit loop after removing the first matching PIN
                            else
                                -- If we reach here and valid count is 1, we don't want to remove it
                                term.setCursorPos(w / 2 - 5, h / 2 + 1)
                                write("Cannot remove; at least one PIN must remain.")
                                sleep(3)
                                return  -- Exit the function or script if we can't remove it
                            end
                        end
                    end
                
                    -- If we removed the PIN, write the updated list back to the file
                    if pinRemoved then
                        local file = fs.open("ids.lua", "w")
                        file.write("return " .. textutils.serialize(ids))
                        file.close()
                        term.setCursorPos(w / 2 - 5, h / 2 + 1)
                        write("Removed PIN.")
                        sleep(3)
                    else
                        term.setCursorPos(w / 2 - 5, h / 2 + 1)
                        write("PIN not found.")
                        sleep(3)
                    end
                elseif num == "1" then
                    term.clear()
                    term.setCursorPos(w / 2 - 5, h / 2 - 1)
                    print("Enter PIN:")
                    term.setCursorPos(w / 2 - 5, h / 2)
                    local id = read("\7")
                    term.clear()
                    term.setCursorPos(1, 1)
                    print("To skip a value, just press enter without typing anything.")
                    write("Seconds valid? ")
                    local exp = read()
                    write("Maximum uses? ")
                    local uses = read()
                    write("Access level? ")
                    local level = tonumber(read()) or 0
                    local ids = dofile("ids.lua")
                    ids[#ids+1] = {id = id, expiration = exp == "" and 0 or os.epoch("utc") + (tonumber(exp) * 1000), uses = uses == "" and -1 or tonumber(uses), level = level}
                    local file = fs.open("ids.lua", "w")
                    file.write("return " .. textutils.serialize(ids))
                    file.close()
                    print("Successfully wrote new PIN.")
                    sleep(3)
                elseif num == "3" then
                    term.clear()
                    term.setCursorPos(w / 2 - 5, h / 2 - 1)
                    print("Enter PIN:")
                    term.setCursorPos(w / 2 - 5, h / 2)
                    local id = read("\7")
                    local ids = dofile("ids.lua")
                    local found
                    for _, v in ipairs(ids) do if v.id == id then found = v end end
                    if found then
                        term.clear()
                        term.setCursorPos(1, 1)
                        print("To skip a value, just press enter without typing anything.")
                        write("Seconds valid? ")
                        local exp = read()
                        write("Maximum uses? ")
                        local uses = read()
                        write("Access level? ")
                        local level = tonumber(read())
                        found.expiration = tonumber(exp) and os.epoch("utc") + (tonumber(exp) * 1000) or found.expiration
                        found.uses = tonumber(uses) or found.uses
                        found.level = level or found.level
                        local file = fs.open("ids.lua", "w")
                        file.write("return " .. textutils.serialize(ids))
                        file.close()
                        print("Successfully updated PIN.")
                        sleep(3)
                    else
                        term.setCursorPos(w / 2 - 5, h / 2 + 1)
                        term.setTextColor(colors.red)
                        term.write("Unknown PIN.")
                        term.setTextColor(colors.white)
                        sleep(3)
                    end
                elseif num == "4" then
                    local lines = {{"ID", "PIN", "Level", "Expires", "Uses Left"}}
                    local ids = dofile("ids.lua")
                    for i, v in ipairs(ids) do
                        lines[#lines+1] = {tostring(i), v.id, tostring(v.level), v.expiration == 0 and "Never" or os.date("!%c", v.expiration / 1000), v.uses == -1 and "Infinite" or tostring(v.uses)}
                    end
                    term.clear()
                    term.setCursorPos(1, 1)
                    textutils.pagedTabulate(table.unpack(lines))
                    print("Press enter to exit.")
                    read()
                elseif num == "5" then
                    break
                end
            end
        else
            term.setCursorPos(w / 2 - 10, h / 2 + 2)
            term.setTextColor(colors.red)
            term.write("Incorrect password.")
            term.setTextColor(colors.white)
            sleep(3)
        end
    end
end)
end)

if not ok then
    printError(err)
    sleep(5)
end

os.reboot()