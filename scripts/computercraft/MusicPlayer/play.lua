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
local isPaused = false
local quit = false
local isLoopEnabled = false

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

function updateURI()
    if isShuffleEnabled then
        if #songs == 0 then
            print("No more songs available to play. Reshuffling...")
            songs = fs.list("songs/")
            shuffleSongs() -- Reshuffle the songs
        end
        selectedSong = songs[1] -- Get the next song
        uri = "songs/" .. selectedSong
    else
        -- If looping is enabled
        if isLoopEnabled then
            uri = "songs/" .. selectedSong -- Looping the same song
        else
            selectedSong = songs[1] -- Get the next song
            table.remove(songs, 1) -- Remove the played song from the list
            if #songs == 0 then
                print("No more songs in the playlist. Reshuffling...")
                songs = fs.list("songs/")
                shuffleSongs() -- Reshuffle the songs
            else
                selectedSong = songs[1] -- Get the next song
                uri = "songs/" .. selectedSong
            end
        end
    end
end

function play()
    while true do
        if isShuffleEnabled then
            songs = fs.list("songs/")
            shuffleSongs() -- Shuffle the songs
            selectedSong = songs[1] -- Assume selecting the first shuffled song
            updateURI()
        end

        if not selectedSong then
            print("No song selected to play.")
            break -- Exit loop if there's no song selected
        end

        print("Now playing: " .. (selectedSong or "No song selected"))
        local response = nil
        local uri = "" 

        -- Wait until the new response is available
        while not response do
            if isPaused then
                -- Wait for a signal to continue playing
                os.pullEvent("resume")
            end
            
            -- Update URI and check if there's a new response
            local tempURI = updateURI()

            -- Check if there was a URI change
            if tempURI ~= uri then
                -- If there's a new URI, get the new response for it
                uri = tempURI 
                response = http.get(uri, nil, true)
            end
        end

        local chunkSize = 4 * 1024
        local chunk
        while true do
            if isPaused then
                -- Wait for a signal to continue playing
                os.pullEvent("resume")
            end
            
            -- Read a chunk
            chunk = response.read(chunkSize)

            -- End of the song reached
            if not chunk then
                print("Song ended: " .. (selectedSong or "Unknown song"))
                break
            end

            local buffer = decoder(chunk)
            while not playChunk(buffer) do
                os.pullEvent("speaker_audio_empty")
            end
        end
    end
end

function readUserInput()
    local commands = {
        ["stop"] = function()
            print("Stopping the media center.")
            quit = true
        end,
        ["shuffle"] = function()
            isShuffleEnabled = not isShuffleEnabled
            print("Shuffle is now " .. (isShuffleEnabled and "enabled" or "disabled"))
        end,
        ["pause"] = function()
            isPaused = not isPaused
            if isPaused then
                print("Media is paused. Type 'resume' to continue.")
            else
                print("Media is playing now.")
                os.queueEvent("resume")  -- Trigger the resume event
            end
        end,
        ["skip"] = function()
            print("Skipping to the next song.")
            updateURI() -- Update the URI to the next song
        end,
        ["loop"] = function()
            isLoopEnabled = not isLoopEnabled
            print("Loop is now " .. (isLoopEnabled and "enabled" or "disabled"))
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
        if command then
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