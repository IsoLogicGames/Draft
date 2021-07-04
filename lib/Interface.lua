--- Provides the Interface function.
--
-- @module Interface

local module = script.Parent
local Meta = require(module.Meta)
local Object = require(module.Object)

local ErrorName = "Cannot create an interface with name of type '%s'."
local ErrorImplement = "Cannot create an interface implementing a parent of type '%s'."
local ErrorMeta = "Cannot create an interface implementing an inaccessible class."
local ErrorInterface = "Cannot create an interface implementing a non-interface."
local ErrorClass = "Cannot create an interface implementing a class."

--- Ensures an object contains a class table and is not a class.
-- Raises an error if there is a problem with the provided object.
--
-- @param interface the object to check for a class table
-- @raise
-- * if interface is not a table
-- * if interface has no metatable
-- * if interface has no class table
-- * if interface is a class
local function validateInterface(interface)
	local typeInterface = type(interface)
	if typeInterface ~= "table" then
		error(string.format(ErrorImplement, typeInterface))
	end
	local interfaceMeta = getmetatable(interface)
	if type(interfaceMeta) ~= "table" then
		error(ErrorMeta)
	end
	local interfaceClass = interfaceMeta.__class
	if type(interfaceClass) ~= "table" then
		error(ErrorInterface)
	end
	if interfaceClass.parent ~= nil or interface == Object then
		error(ErrorClass)
	end
end

--- Creates a new interface.
--
-- @param name the name of the new interface
-- @param[opt] ... any number of implemented interfaces
-- @return the new interface
-- @raise
-- * if the name is not a string
-- * if an interface is not a table
-- * if an interface has no metatable
-- * if an interface has no class table
-- * if an interface is a class
-- @usage
-- local MyInterface = Interface("MyInterface")
-- local MySubInterface = Interface("MySubInterface", MyInterface)
-- @function Interface
local function Interface(name, ...)
	local typeName = type(name)
	if typeName ~= "string" then
		error(string.format(ErrorName, typeName))
	end
	local interface = {}
	local meta = {}
	local class = {}
	interface.__meta = meta
	for key, value in pairs(Meta) do
		meta[key] = value
	end
	meta.__class = class
	class.name = name
	class.implementing = {}
	class.interface = {}
	for _, interface in ipairs({ ... }) do
		validateInterface(interface)
		table.insert(class.implementing, interface)
	end
	setmetatable(interface, meta)
	return interface
end

return Interface
