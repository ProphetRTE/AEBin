-- Root URL for the GitHub songs directory
local rootUrl = "https://github.com/ProphetRTE/AEBin/raw/refs/heads/master/scripts/computercraft/Music%20Scripts/Music/"

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
    -- Add more song names as needed
}

-- Function to execute the command to save a song
local function saveToDevice(songName, songUrl)
    local formattedName = songName:gsub("%%20", " ")  -- Decode %20 to spaces
    local command = "savetodevice " .. "\"" .. formattedName .."\" " ..  " \"" .. songUrl .. "\""
    shell.run(command)  -- Execute the command
end

-- Loop through the song names and save each one
for _, songName in ipairs(songNames) do
    local songUrl = rootUrl .. songName .. ".dfpwm"  -- Construct the full URL
    saveToDevice(songName, songUrl)  -- Call the saving function
end

print("All songs have been saved to the device.")