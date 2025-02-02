os.loadAPI("lib/aecord")
os.loadAPI("lib/aeprint")
os.loadAPI("lib/aeprogress")

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
    aeprint.aeprint("Welcome to the Song Request System", 0)

    -- Ask for the author
    local author = readInput("Enter the author: ")
    
    -- Ask for the song name
    local songName = readInput("Enter the song name: ")

    
    local songRequestee = readInput("Who is requesting the song: ")

    local songLink = readInput("Enter the song link(Type N/A if you don't want to find it.): ")

    -- Print the formatted message
    actionTable = {}
    actionTable[1] = function()
        if songLink == "N/A" then
            hook.sendEmbed("", "New Song Suggestion", string.format("%s - %s", author, songName), nil, 0xFF00FF, nil, nil, songRequestee, nil)
        else
            hook.sendEmbed("", "New Song Suggestion", string.format("%s - %s", author, songName), songLink, 0xFF00FF, nil, nil, songRequestee, nil)
        end
    end
    
    aeprogress.bar(actionTable, false)
    aeprint.aeprint("Your song request has been sent to the server!", 0)
end

-- Execute the song request command
songrequest()