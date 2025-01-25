local dfpwm = require("cc.audio.dfpwm")
local speakers = { peripheral.find("speaker") }
local drive = peripheral.find("drive")
local decoder = dfpwm.make_decoder()

local menu = require "menu"
local math_random = math.random
local songs = {}
local uri = nil
local volume = settings.get("media_center.volume")
local selectedSong = nil
local isShuffleEnabled = false

if drive == nil or not drive.isDiskPresent() then
    local savedSongs = fs.list("songs/")
    
    if #savedSongs == 0 then
        error("ERR - No disk was found in the drive, or no drive was found. No sound files were found saved to device.")
    else
        local entries = {
            [1] = {
                label = "[CANCEL]",
                callback = function()
                    error()
                end
            }
        }

        for i, fp in ipairs(savedSongs) do
            table.insert(entries, {
                label = fp:match("^([^.]+)"),
                callback = function()
                    selectedSong = fp

                    menu.exit()
                end
            })
        end

        menu.init({
            main = {
                entries = entries
            }
        })

        menu.thread()

        if selectedSong ~= nil then
            local fp = "songs/" .. selectedSong

            if fs.exists(fp) then
                local file = fs.open(fp, "r")

                uri = file.readAll()

                file.close()
            else
                print("Song was not found on device!")

                return
            end
        else error() end
    end
else
    local songFile = fs.open("disk/song.txt", "r")
    uri = songFile.readAll()

    songFile.close()
end

if uri == nil or not uri:find("^https") then
    print("ERR - Invalid URI!")
    return
end

function playChunk(chunk)
    local returnValue = nil
    local callbacks = {}

    for i, speaker in pairs(speakers) do
        if i > 1 then
            table.insert(callbacks, function()
                speaker.playAudio(chunk, volume or 1.0)
            end)
        else
            table.insert(callbacks, function()
                returnValue = speaker.playAudio(chunk, volume or 1.0)
            end)
        end
    end

    parallel.waitForAll(table.unpack(callbacks))

    return returnValue
end

-- Function to shuffle the songs
function shuffleSongs()
    if #songs == 0 then return end
    for i = #songs, 2, -1 do
        local j = math_random(i)
        songs[i], songs[j] = songs[j], songs[i]
    end
end

if drive == nil or not drive.isDiskPresent() then
    local songName = string.gsub(selectedSong, ".txt", "")
    print("Playing '" .. songName .. "' at volume " .. (volume or 1.0))
else
    print("Playing '" .. drive.getDiskLabel() .. "' at volume " .. (volume or 1.0))
end

local quit = false

function play()
    while true do
        -- Shuffle logic
        if isShuffleEnabled then
            songs = fs.list("songs/")
            shuffleSongs()
            selectedSong = songs[1]  -- Get the first song after shuffle
        end

        local response = http.get(uri, nil, true)

        local chunkSize = 4 * 1024
        local chunk = response.read(chunkSize)
        while chunk ~= nil do
            local buffer = decoder(chunk)

            while not playChunk(buffer) do
                os.pullEvent("speaker_audio_empty")
            end

            chunk = response.read(chunkSize)
        end

        if isShuffleEnabled then
            table.remove(songs, 1)  -- Remove the played song from the list
            if #songs == 0 then
                isShuffleEnabled = false  -- Disable shuffle if no more songs
            else
                selectedSong = songs[1]  -- Get the next song
                uri = "songs/" .. selectedSong  -- Set the next URI to be played
            end
        end
    end
end

function readUserInput()
    local commands = {
        ["stop"] = function()
            quit = true
        end,
        ["shuffle"] = function()
            isShuffleEnabled = not isShuffleEnabled
            print("Shuffle is now " .. (isShuffleEnabled and "enabled" or "disabled"))
        end
    }

    while true do
        local input = string.lower(read())
        local commandName = ""
        local cmdargs = {}

        local i = 1
        for word in input:gmatch("%w+") do
            if i > 1 then
                table.insert(cmdargs, word)
            else
                commandName = word
            end
            i = i + 1
        end

        local command = commands[commandName]

        if command ~= nil then
            command(table.unpack(cmdargs))
        else 
            print('"' .. cmdargs[1] .. '" is not a valid command!') 
        end
    end
end

function waitForQuit()
    while not quit do
        sleep(0.1)
    end
end

parallel.waitForAny(play, readUserInput, waitForQuit)