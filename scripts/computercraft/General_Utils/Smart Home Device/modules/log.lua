-----------------------------------------------------------------------------
--  Logs formatted console messages.
--
--	Version: 1.0.1
-----------------------------------------------------------------------------

--- Prints a formatted message to the console
-- @param message 	The message to display
-- @param level		(Optional) A number indicating the message level
--					  1 - (default) Standard message
--					  2 - Success message
--					  3 - Error message
function log(message, level)
	level = level or 1
	local levels = {
		colors.white,
		colors.lime,
		colors.red
	}
	local originalColor = term.getTextColor()
	local colorChanged = (levels[level] ~= originalColor)

	io.write('*')
	term.setTextColor(colors.yellow)
	io.write(' [' .. textutils.formatTime(os.time(), true) .. '] ')
	term.setTextColor(originalColor)

	if levels[level] ~= nil and colorChanged then
		term.setTextColor(levels[level])
	end

	io.write(message .. '\n')

	if colorChanged then
		term.setTextColor(originalColor)
	end
end

return log