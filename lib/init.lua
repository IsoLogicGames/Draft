--- The Draft class API.
-- Provides access to all library functions and classes.
--
-- @module Draft
-- @release 0.1.0
-- @license MIT

local Draft = {}
local instance

Draft.__index = Draft

--- Creates the Draft API singleton.
-- This is called automatically and will only ever create a maximum of one
-- object. There is typically no need to explicitly call this.
--
-- @return the Draft API
-- @local
-- @access private
function Draft.new()
	if instance == nil then
		local self = setmetatable({}, Draft)
		instance = self
	end
	return instance
end

return Draft.new()
