local mon = peripheral.find("monitor")
local background = false
if mon == nil and not background then
    shell.run("[File_Name]")
else if mon == nil and background then
    shell.run("bg [File_Name]")
else if mon == not nil and not background then
    shell.run("monitor "..peripheral.getName(mon).." [File_name]")
else
    shell.run("bg monitor "..peripheral.getName(mon).." [File_name]")
end