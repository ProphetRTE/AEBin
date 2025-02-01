os.loadAPI("lib/aecord")
local aeprint = require("lib/aeprint")

local success, hook = aecord.createWebhook("https://discordapp.com/api/webhooks/... (THE URL YOU GOT FROM DISCORD)")
if not success then
    error("Webhook connection failed! Reason: " .. hook)
end

-- Function to ask for user input
function readInput(prompt)
    write(prompt)
    return read()
end

-- Main function for the mod suggestion command
function modSuggestion()
    aeprint.aeprint("Welcome to the Mod Suggestion System")

    -- Ask for the author of the mod
    local author = readInput("Enter the author of the mod: ")
    
    -- Ask for the name of the mod
    local modName = readInput("Enter the name of the mod: ")

    local modRequestee = readInput("Who is requesting the mod: ")

    local modLink = readInput("Enter the mod link(Type N/A if you don't want to find it.): ")

    -- Print the formatted message
    if modLink == "N/A" then
        hook.sendEmbed("", "New Mod Suggestion", string.format("%s - %s", author, songName), nil, 0xFF00FF, nil, nil, modRequestee, nil)
    else
        hook.sendEmbed("", "New Mod Suggestion", string.format("%s - %s", author, songName), songLink, 0xFF00FF, nil, nil, modRequestee, nil)
    end
    aeprint.aeprint("Your mod suggestion has been sent to the server!")
end

-- Execute the mod suggestion command
modSuggestion()