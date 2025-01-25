local AECord = require("/AECord")

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
    print("Welcome to the Mod Suggestion System")

    -- Ask for the author of the mod
    local author = readInput("Enter the author of the mod: ")
    
    -- Ask for the name of the mod
    local modName = readInput("Enter the name of the mod: ")

    -- Construct and send the embed message
    hook.sendEmbed(string.format("%s - %s", author, modName), "New Mod Suggestion", "Someone just suggested a new mod!", nil, 0x00FF00, nil, nil, nil, nil)
    print("Your mod suggestion has been sent to the server!")
end

-- Execute the mod suggestion command
modSuggestion()