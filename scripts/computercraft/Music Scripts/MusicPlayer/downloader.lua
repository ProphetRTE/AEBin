local uri = "https://raw.githubusercontent.com/ProphetRTE/AEBin/refs/heads/master/scripts/computercraft/Music%20Scripts/MusicPlayer/install.lua"
local file = fs.open("install.lua", "w")

local response = http.get(uri)

file.write(response.readAll())
file.close()

term.clear()

print("Installer downloaded. Please run the 'install' command now.")
print("WARNING - CHANGES TO THIS COMPUTER CANNOT BE UNDONE AFTER RUNNING INSTALL, FILES MAY BE OVERWRITTEN. PLEASE USE AN UNMODIFIED COMPUTER TO PREVENT DATA LOSS OR CONFLICTS.")