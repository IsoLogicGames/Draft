--- The Interface function.
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
