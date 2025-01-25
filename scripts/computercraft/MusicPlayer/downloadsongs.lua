-- Root URL for the GitHub songs directory
local rootUrl = "https://cc.prophecypixel.com/music/"
local musicList = rootUrl .. "music_list.txt"
local songsFolder = "songs/"

-- Function to get the list of songs from the server
local function getServerMusicList()
    local response = http.get(musicList)
    if response then
        local content = response.readAll()
        response.close()  -- Close the response to prevent memory leaks
        -- Split the content into a list based on newlines
        local songs = {}
        for line in content:gmatch("[^\r\n]+") do
            table.insert(songs, line)
        end
        return songs  -- Return the list of songs
    end
    return {}  -- Return an empty table if the response is nil
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
        --print(songName .. " already exists. Skipping download.")
    else    
        print("Downloading " .. songName .. "\n")  -- Inform the user
        local command = "savetodevice " .. "\"" .. songName .. "\" " .. rootUrl .. formattedName .. ".dfpwm"  -- Construct the command with the formatted name
        shell.run(command)  -- Execute the command
    end
end

-- Main logic
local serverSongs = getServerMusicList()  -- Get the list of songs from the server
local localSongs = getLocalSongsList()  -- Get the current songs in the songs folder
print("Checking for new songs...")
if #serverSongs == 0 then
    print("No songs found on the server.")
    return
end
print("[" .. #serverSongs .. "]" .. " songs found on the server.")
print("[" .. #localSongs .. "]" .. " songs found locally.")
if #serverSongs == #localSongs then
    print("All songs are up to date.")
    return
end

-- Compare and save new songs
for _, songName in ipairs(serverSongs) do
    if not table.contains(localSongs, songName) then
        saveToDevice(songName)  -- Save the new song
    else
        --print(songName .. " already exists in the songs folder. Skipping.")
    end
end

if #serverSongs ~= #localSongs then
    print("All songs have downloaded successfully.")
end
