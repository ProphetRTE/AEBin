local mon = peripheral.find("monitor")
local background = false
if mon == nil and not background then
    shell.run("File_Name")
elseif mon == nil and background then
    shell.run("bg [File_Name]")
elseif mon ~= nil and not background then
    shell.run("monitor "..peripheral.getName(mon).." [File_name]")
elseif mon ~= nil and background then
    shell.run("bg monitor "..peripheral.getName(mon).." [File_name]")
end
