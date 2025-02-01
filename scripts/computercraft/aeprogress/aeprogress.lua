function aeprogress(pTable, hidden)
	local termWidth, termHeight = term.getSize()
	local ogTerm = term.current()
	local bgWindow = window.create(ogTerm, 1, 1, termWidth, termHeight, false)

	-- All customizable values.
	local barWidth = math.floor(termWidth*.75)
	local fullChar = " "
	local emptyChar = "\143"
	local bg = "f"
	local fg = "0"

	-- Draws the empty progress bar.
	local mouseX, mouseY = term.getCursorPos()
	term.setCursorPos(termWidth/2-barWidth/2, mouseY)
	term.blit(emptyChar:rep(barWidth), bg:rep(barWidth), fg:rep(barWidth))

	-- Iterates through the table and performs functions.
	for key, value in pairs(pTable) do
		if hidden then term.redirect(bgWindow) end
		value()
		term.redirect(ogTerm)
	-- Draws 'full characters' to the progress bar as the action finishes.
		term.setCursorPos(termWidth/2-barWidth/2, mouseY)
		term.blit(fullChar:rep(math.floor(key / #pTable * barWidth)), bg:rep(math.floor(key / #pTable * barWidth)), fg:rep(math.floor(key / #pTable * barWidth)))
	end
	term.setCursorPos(mouseX, mouseY+1)
end

return aeprogress