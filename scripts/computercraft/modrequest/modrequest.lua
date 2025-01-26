os.loadAPI("lib/aecord")
os.loadAPI("lib/aeprint")

local success, hook = AECord.createWebhook("https://discordapp.com/api/webhooks/... (THE URL YOU GOT FROM DISCORD)")
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

    -- Construct and send the embed message
    hook.sendEmbed(nill, "New Mod Suggestion", string.format("%s - %s", author, modName), nil, 0x00FF00, nil, nil, modRequestee, nil)
    aeprint.aeprint("Your mod suggestion has been sent to the server!")
end

-- Execute the mod suggestion command
modSuggestion()