-----------------------------------------------------------------------------
--  This package provides a function that splits a string into a table of 
--  substrings.
--
--	Version: 1.0.3
-----------------------------------------------------------------------------

--- Split a string containing space-separated words into a table of words
-- @param str 	The string to split
-- @return 			Returns a table of words as strings 
function split(str)
	if type(str) ~= 'string' then return end

	local tbl = {}
	local i = 1
	for word in string.gmatch(str, "%S+") do
		tbl[i] = word
		i = i + 1
	end

	return tbl
end

return split