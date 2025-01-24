local baseUri = "https://cc.prophecypixel.com/scripts/computercraft/MusicPlayer/"
local files = { "help", "play", "save", "savetodevice", "startup", "menu", "setvolume", "downloadSongs" }

term.clear()

for _, file in pairs(files) do
	print("Downloading program '" .. file .. "'...")

	local fileInstance = fs.open(file .. ".lua", "w")
	local response = http.get(baseUri .. file .. ".lua")

	fileInstance.write(response.readAll())
	fileInstance.close()
end

local updateUri = "https://cc.prophecypixel.com/scripts/computercraft/MusicPlayer/version.txt"

local updateResponse = http.get(updateUri)
local updateFile = fs.open("version.txt", "w")

updateFile.write(updateResponse.readAll())

print("Installation complete! Please restart your computer.")
