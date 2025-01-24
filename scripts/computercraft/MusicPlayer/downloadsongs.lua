-- Root URL for the GitHub songs directory
local rootUrl = "https://cc.prophecypixel.com/music/"
local musicList = "music_list.txt"
local songsFolder = "songs/"

-- List of song names (with %20 encoding for spaces)
local songNames = {
    "Aphex%20Twin%20-%20Windowlicker",
    "Bill%20Conti%20-%20Going%20the%20Distance",
    "Deathgrips%20-%20Beware",
    "Enigma%20-%20Return%20To%20Inocence",
    "J-Cut%20&%20Kolt%20Siewerts%20-%20The%20Flute%20Tune",
    "Ludacris%20-%20Move%20Bitch",
    "Prince%20-%20Purple%20Rain",
    "Prince%20Bard%20-%20Purple%20Rain",
    "Queen%20-%20Underpressure",
    "Grieg%20-%20In%20the%20Hall%20of%20the%20Mountain%20King",
    "Harry%20Mack%20-%20No%20Regard",
    "Little%20Stranger%20-%20Brain%20Fog",
    "Ocean%20Noises",
    "Raido%20-%20Wardruna",
    "Sleep%20Token%20-%20Are%20You%20Really%20Okay",
    -- Add more song names as needed
}


-- Function to read the local music list
local function getServerMusicList()
    local response = http.get(rootUrl .. musicList)
    if response then
        local content = response.readAll()
        response.close()
        return textutils.unserialize(content) or {}
    end
    return {}
end

-- Function to get the list of existing songs in the songs folder
local function getLocalSongsList()
    local localSongs = {}
    if fs.exists(songsFolder) then
        for _, file in ipairs(fs.list(songsFolder)) do
            table.insert(localSongs, file:match("^(.*)%.txt$"))  -- Store the song names without the .txt extension
        end
    end
    return localSongs
end

-- Function to execute the command to save a song
local function saveToDevice(songName, songUrl)
    local formattedName = songName:gsub("%%20", " ")
    local filePath = songsFolder .. formattedName .. ".txt"  -- Define the file path

    if fs.exists(filePath) then
        print(formattedName .. " already exists. Skipping download.")
    else    
        local command = "savetodevice " .. "\"" .. formattedName .. "\" " .. songUrl  -- Construct the command
        shell.run(command)  -- Execute the command
    end
end

-- Main logic
local serverSongs = getServerMusicList()  -- Get the list of songs from the server
local localSongs = getLocalSongsList()  -- Get the current songs in the songs folder

-- Compare and save new songs
for _, songName in ipairs(serverSongs) do
    if not table.contains(localSongs, songName) then
        local songUrl = rootUrl .. songName .. ".dfpwm"  -- Construct the full URL
        saveToDevice(songName, songUrl)  -- Save the new song
    else
        print(songName .. " already exists in the songs folder. Skipping.")
    end
end

print("All songs have been saved to the device.")
