local AECord = require("lib/aecord")


local success, hook = AECord.createWebhook("https://discordapp.com/api/webhooks/... (THE URL YOU GOT FROM DISCORD)")
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
    print("Welcome to the Song Request System")

    -- Ask for the author
    local author = readInput("Enter the author: ")
    
    -- Ask for the song name
    local songName = readInput("Enter the song name: ")

    
    local songRequestee = readInput("Who is requesting the song: ")

    -- Print the formatted message
    print()
    hook.sendEmbed(string.format("%s - %s", author, songName), "New Song Request", "Someone just requested a song!", nil, 0xFF00FF, nil, nil, songRequestee, nil)
    print("Your song request has been sent to the server!")
end

-- Execute the song request command
songrequest()