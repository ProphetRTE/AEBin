local rn = {
	protocol = nil,

	init = function(self, protocol)
		self.protocol = protocol
	end
}

return {
	new = function(protocol)
		return rn:init(protocol)
	end
}