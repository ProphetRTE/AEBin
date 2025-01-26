os.loadAPI("lib/aecord")
os.loadAPI("lib/aeprint")

local success, hook = aecord.createWebhook("https://discordapp.com/api/webhooks/... (THE URL YOU GOT FROM DISCORD)")
 if not success then
  error("Webhook connection failed! Reason: " .. hook)
 end

-- Function to ask for user input
function readInput(prompt)
    write(prompt)
    return read()
end

-- Main function for the song request command
function songrequest()
    aeprint.aeprint("Welcome to the Song Request System")

    -- Ask for the author
    local author = readInput("Enter the author: ")
    
    -- Ask for the song name
    local songName = readInput("Enter the song name: ")

    
    local songRequestee = readInput("Who is requesting the song: ")

    -- Print the formatted message
    hook.sendEmbed("", "New Mod Suggestion", string.format("%s - %s", author, songName), nil, 0xFF00FF, nil, nil, songRequestee, nil)
    aeprint.aeprint("Your song request has been sent to the server!")
end

-- Execute the song request command
songrequest()