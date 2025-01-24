-- Root URL for the GitHub songs directory
local rootUrl = "https://cc.prophecypixel.com/music/"
local musicList = "music_list.txt"
local songsFolder = "songs/"

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

-- Helper function to check if a song is in the table
function table.contains(table, val)
    for _, value in ipairs(table) do
        if value == val then
            return true
        end
    end
    return false
end

-- Function to execute the command to save a song
local function saveToDevice(songName)
    local formattedName = songName:gsub(" ", "%%20")  -- Replace spaces with %20 for URL formatting
    local filePath = songsFolder .. songName .. ".txt"  -- Define the file path

    if fs.exists(filePath) then
        print(songName .. " already exists. Skipping download.")
    else    
        local command = "savetodevice " .. "\"" .. songName .. "\" " .. rootUrl .. formattedName .. ".dfpwm"  -- Construct the command with the formatted name
        shell.run(command)  -- Execute the command
    end
end

-- Main logic
local serverSongs = getServerMusicList()  -- Get the list of songs from the server
local localSongs = getLocalSongsList()  -- Get the current songs in the songs folder

-- Compare and save new songs
for _, songName in ipairs(serverSongs) do
    if not table.contains(localSongs, songName) then
        saveToDevice(songName)  -- Save the new song
    else
        print(songName .. " already exists in the songs folder. Skipping.")
    end
end

print("All songs have been saved to the device.")
