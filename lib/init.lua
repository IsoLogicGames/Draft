--- The Draft class API.
-- Provides access to all library functions and classes.
--
-- @module Draft
-- @release 0.1.0
-- @license MIT

local Class = require(script.Class)
local Interface = require(script.Interface)
local Object = require(script.Object)

local Draft = {}
local instance

Draft.__index = Draft

--- The @{Class} function.
--
-- @see Class
Draft.Class = Class

--- The @{Interface} function.
--
-- @see Interface
Draft.Interface = Interface

--- The @{Object} function.
--
-- @see Object
Draft.Object = Object

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
