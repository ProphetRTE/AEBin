-- Save this as startup.lua on each client computer with a 1x1 monitor and modem attached. You can also optionally attach a speaker for audio feedback.
local secret = "" -- Set this to the same secret that was set in the server file.
local redstoneSide = "left" -- Set this to the side the redstone signal should be output on.
local openTime = 5 -- Set this to the number of seconds to keep the door open for.
local defaultOutput = false -- Set this to the default redstone state for the door. If set to true, this means power will be cut when unlocking.
                            -- This allows you to place a door sideways, and then have it stay closed even when power is applied externally.\
local accessLevel = 0 -- Set this to the minimum access level required by a PIN.

if not secret or secret == "" then error("Please set some keys inside the script before running.") end

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
        for i = 1, 64 do
            local s0 = bit32.bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
            local maj = bit32.bxor(bit32.band(a, b), bit32.band(a, c), bit32.band(b, c))
            local t2 = s0 + maj
            local s1 = bit32.bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
            local ch = bit32.bxor(bit32.band(e, f), bit32.band(bit32.bnot(e), g))
            local t1 = h + s1 + ch + k[i] + w[i]
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

local speaker = peripheral.find("speaker")
local modem = peripheral.find("modem")
modem.open(74)
redstone.setOutput(redstoneSide, defaultOutput)

-- PrimeUI by JackMacWindows
-- Public domain/CC0

local expect = require "cc.expect".expect

-- Initialization code
local PrimeUI = {}
do
    local coros = {}
    local restoreCursor

    --- Adds a task to run in the main loop.
    ---@param func function The function to run, usually an `os.pullEvent` loop
    function PrimeUI.addTask(func)
        expect(1, func, "function")
        local t = {coro = coroutine.create(func)}
        coros[#coros+1] = t
        _, t.filter = coroutine.resume(t.coro)
    end

    --- Sends the provided arguments to the run loop, where they will be returned.
    ---@param ... any The parameters to send
    function PrimeUI.resolve(...)
        coroutine.yield(coros, ...)
    end

    --- Clears the screen and resets all components. Do not use any previously
    --- created components after calling this function.
    function PrimeUI.clear()
        -- Reset the screen.
        term.setCursorPos(1, 1)
        term.setCursorBlink(false)
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        -- Reset the task list and cursor restore function.
        coros = {}
        restoreCursor = nil
    end

    --- Sets or clears the window that holds where the cursor should be.
    ---@param win window|nil The window to set as the active window
    function PrimeUI.setCursorWindow(win)
        expect(1, win, "table", "nil")
        restoreCursor = win and win.restoreCursor
    end

    --- Gets the absolute position of a coordinate relative to a window.
    ---@param win window The window to check
    ---@param x number The relative X position of the point
    ---@param y number The relative Y position of the point
    ---@return number x The absolute X position of the window
    ---@return number y The absolute Y position of the window
    function PrimeUI.getWindowPos(win, x, y)
        if win == term then return x, y end
        while win ~= term.native() and win ~= term.current() and not win.setTextScale do
            if not win.getPosition then return x, y end
            local wx, wy = win.getPosition()
            x, y = x + wx - 1, y + wy - 1
            _, win = debug.getupvalue(select(2, debug.getupvalue(win.isColor, 1)), 1) -- gets the parent window through an upvalue
        end
        return x, y
    end

    --- Runs the main loop, returning information on an action.
    ---@return any ... The result of the coroutine that exited
    function PrimeUI.run()
        while true do
            -- Restore the cursor and wait for the next event.
            if restoreCursor then restoreCursor() end
            local ev = table.pack(os.pullEvent())
            -- Run all coroutines.
            for _, v in ipairs(coros) do
                if v.filter == nil or v.filter == ev[1] then
                    -- Resume the coroutine, passing the current event.
                    local res = table.pack(coroutine.resume(v.coro, table.unpack(ev, 1, ev.n)))
                    -- If the call failed, bail out. Coroutines should never exit.
                    if not res[1] then error(res[2], 2) end
                    -- If the coroutine resolved, return its values.
                    if res[2] == coros then return table.unpack(res, 3, res.n) end
                    -- Set the next event filter.
                    v.filter = res[2]
                end
            end
        end
    end
end

--- Creates a clickable button on screen with text.
---@param win window The window to draw on
---@param x number The X position of the button
---@param y number The Y position of the button
---@param text string The text to draw on the button
---@param action function|string A function to call when clicked, or a string to send with a `run` event
---@param fgColor color|nil The color of the button text (defaults to white)
---@param bgColor color|nil The color of the button (defaults to light gray)
---@param clickedColor color|nil The color of the button when clicked (defaults to gray)
function PrimeUI.button(win, x, y, text, action, fgColor, bgColor, clickedColor)
    expect(1, win, "table")
    expect(2, x, "number")
    expect(3, y, "number")
    expect(4, text, "string")
    expect(5, action, "function", "string")
    fgColor = expect(6, fgColor, "number", "nil") or colors.white
    bgColor = expect(7, bgColor, "number", "nil") or colors.gray
    clickedColor = expect(8, clickedColor, "number", "nil") or colors.lightGray
    -- Draw the initial button.
    win.setCursorPos(x, y)
    win.setBackgroundColor(bgColor)
    win.setTextColor(fgColor)
    win.write(" " .. text .. " ")
    -- Get the screen position and add a click handler.
    PrimeUI.addTask(function()
        local buttonDown = false
        while true do
            local event, button, clickX, clickY = os.pullEvent()
            local screenX, screenY = PrimeUI.getWindowPos(win, x, y)
            if event == "mouse_click" and button == 1 and clickX >= screenX and clickX < screenX + #text + 2 and clickY == screenY then
                -- Initiate a click action (but don't trigger until mouse up).
                buttonDown = true
                -- Redraw the button with the clicked background color.
                win.setCursorPos(x, y)
                win.setBackgroundColor(clickedColor)
                win.setTextColor(fgColor)
                win.write(" " .. text .. " ")
            elseif event == "mouse_up" and button == 1 and buttonDown then
                -- Finish a click event.
                if clickX >= screenX and clickX < screenX + #text + 2 and clickY == screenY then
                    -- Trigger the action.
                    if type(action) == "string" then PrimeUI.resolve("button", action)
                    else action() end
                end
                -- Redraw the original button state.
                win.setCursorPos(x, y)
                win.setBackgroundColor(bgColor)
                win.setTextColor(fgColor)
                win.write(" " .. text .. " ")
            elseif event == "monitor_touch" and win.setTextScale and peripheral.getName(win) == button and clickX >= screenX and clickX < screenX + #text + 2 and clickY == screenY then
                -- Redraw the button with the clicked background color.
                win.setCursorPos(x, y)
                win.setBackgroundColor(clickedColor)
                win.setTextColor(fgColor)
                win.write(" " .. text .. " ")
                -- Trigger a click event.
                if type(action) == "string" then PrimeUI.resolve("button", action)
                else action() end
                -- Pause to indicate clicked.
                sleep(0.25)
                -- Redraw the original button state.
                win.setCursorPos(x, y)
                win.setBackgroundColor(bgColor)
                win.setTextColor(fgColor)
                win.write(" " .. text .. " ")
            end
        end
    end)
end

--- Draws a line of text, centering it inside a box horizontally.
---@param win window The window to draw on
---@param x number The X position of the left side of the box
---@param y number The Y position of the box
---@param width number The width of the box to draw in
---@param text string The text to draw
---@param fgColor color|nil The color of the text (defaults to white)
---@param bgColor color|nil The color of the background (defaults to black)
function PrimeUI.centerLabel(win, x, y, width, text, fgColor, bgColor)
    expect(1, win, "table")
    expect(2, x, "number")
    expect(3, y, "number")
    expect(4, width, "number")
    expect(5, text, "string")
    fgColor = expect(6, fgColor, "number", "nil") or colors.white
    bgColor = expect(7, bgColor, "number", "nil") or colors.black
    assert(#text <= width, "string is too long")
    win.setCursorPos(x + math.floor((width - #text) / 2), y)
    win.setTextColor(fgColor)
    win.setBackgroundColor(bgColor)
    win.write(text)
end

local monitor = peripheral.find("monitor")
monitor.setTextScale(0.5)
local w, h = monitor.getSize()
local w3 = w / 3
local h5 = h / 5
local text = ""
local function updateText(t)
    text = text .. t
    monitor.setCursorPos(1, h5 / 2 + 1)
    monitor.setBackgroundColor(colors.black)
    monitor.clearLine()
    PrimeUI.centerLabel(monitor, 1, h5 / 2 + 1, w, ("\7"):rep(#text))
end
PrimeUI.clear()
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)
monitor.clear()
PrimeUI.centerLabel(monitor, 1, h5 / 2, w, "Enter PIN:")
PrimeUI.button(monitor, 0 * w3 + w3 / 2, 1 * h5 + h5 / 2, "1", function() updateText "1" end)
PrimeUI.button(monitor, 1 * w3 + w3 / 2, 1 * h5 + h5 / 2, "2", function() updateText "2" end)
PrimeUI.button(monitor, 2 * w3 + w3 / 2, 1 * h5 + h5 / 2, "3", function() updateText "3" end)
PrimeUI.button(monitor, 0 * w3 + w3 / 2, 2 * h5 + h5 / 2, "4", function() updateText "4" end)
PrimeUI.button(monitor, 1 * w3 + w3 / 2, 2 * h5 + h5 / 2, "5", function() updateText "5" end)
PrimeUI.button(monitor, 2 * w3 + w3 / 2, 2 * h5 + h5 / 2, "6", function() updateText "6" end)
PrimeUI.button(monitor, 0 * w3 + w3 / 2, 3 * h5 + h5 / 2, "7", function() updateText "7" end)
PrimeUI.button(monitor, 1 * w3 + w3 / 2, 3 * h5 + h5 / 2, "8", function() updateText "8" end)
PrimeUI.button(monitor, 2 * w3 + w3 / 2, 3 * h5 + h5 / 2, "9", function() updateText "9" end)
PrimeUI.button(monitor, 0 * w3 + w3 / 2, 4 * h5 + h5 / 2, "\x11", function()
    text = text:sub(1, -2)
    updateText ""
end, colors.white, colors.red)
PrimeUI.button(monitor, 1 * w3 + w3 / 2, 4 * h5 + h5 / 2, "0", function() updateText "0" end)
PrimeUI.button(monitor, 2 * w3 + w3 / 2, 4 * h5 + h5 / 2, "\x10", function()
    local id = text
    local found = false
    local msg = sha256("?:" .. id .. tostring(math.floor(os.epoch("utc") / 1000) .. secret))
    local channel = math.random(0, 65533)
    while channel == 74 do channel = math.random(0, 65533) end
    modem.open(channel)
    modem.transmit(74, channel, "?" .. accessLevel .. ":" .. msg)
    local timer = os.startTimer(3)
    while true do
        local ev2, side2, port, reply, message = os.pullEvent()
        if ev2 == "timer" and side2 == timer then break
        elseif ev2 == "modem_message" and port == channel and reply == 74 and type(message) == "string" and message:sub(1, 2) == "=:" then
            if message == "=:" .. sha256("=:" .. id .. tostring(math.floor(os.epoch("utc") / 1000)) .. secret .. "true") or
                message == "=:" .. sha256("=:" .. id .. tostring(math.floor(os.epoch("utc") / 1000) - 1) .. secret .. "true") then found = true break
            elseif message == "=:" .. sha256("=:" .. msg .. secret .. "false") then found = false break end
        end
    end
    modem.close(channel)
    if found then
        monitor.setCursorPos(1, h5 / 2 + 1)
        monitor.setBackgroundColor(colors.black)
        monitor.clearLine()
        PrimeUI.centerLabel(monitor, 1, h5 / 2 + 1, w, "Success.", colors.green)
        monitor.setTextColor(colors.white)
        redstone.setOutput(redstoneSide, not defaultOutput)
        if speaker then speaker.playNote("bit", 1, 24) end
        sleep(openTime)
        redstone.setOutput(redstoneSide, defaultOutput)
    elseif speaker then
        monitor.setCursorPos(1, h5 / 2 + 1)
        monitor.setBackgroundColor(colors.black)
        monitor.clearLine()
        PrimeUI.centerLabel(monitor, 1, h5 / 2 + 1, w, "Denied.", colors.red)
        monitor.setTextColor(colors.white)
        for i = 1, 3 do
            speaker.playNote("bit", 1, 12)
            if i < 3 then sleep(0.2) end
        end
        sleep(1)
    end
    text = ""
    updateText ""
end, colors.white, colors.green)
PrimeUI.run()
end)

if not ok then
    printError(err)
    sleep(5)
end

os.reboot()