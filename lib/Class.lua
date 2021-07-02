--- The Class function.
--
-- @module Class

local module = script.Parent
local Interface = require(module.Interface)
local Object = require(module.Object)

local ErrorName = "Cannot create a class with name of type '%s'."
local ErrorInherit = "Cannot create a class inheriting from parent of type '%s'."
local ErrorMeta = "Cannot create a class inheriting from an inaccessible class."
local ErrorClass = "Cannot create a class inheriting from non-class or non-interface."
local ErrorMultiple = "Cannot create a class inheriting from multiple non-interface parents."

local function validateClass(class)
	local typeClass = type(class)
	if typeClass ~= "table" then
		error(string.format(ErrorInherit, typeClass))
	end
	local classMeta = getmetatable(class)
	if type(classMeta) ~= "table" then
		error(ErrorMeta)
	end
	local classTable = classMeta.__class
	if type(classTable) ~= "table" then
		error(ErrorClass)
	end
end

local function separate(parents)
	local classes = {}
	local interfaces = {}
	for _, class in ipairs(parents) do
		validateClass(class)
		if getmetatable(class).__class.parent ~= nil or class == Object then
			table.insert(classes, class)
		else
			table.insert(interfaces, class)
		end
	end
	return classes, interfaces
end

local function Class(name, ...)
	local typeName = type(name)
	if typeName ~= "string" then
		error(string.format(ErrorName, typeName))
	end
	local classes, interfaces = separate({ ... })
	if #classes > 1 then
		error(ErrorMultiple)
	end
	local class = Interface(name, unpack(interfaces))
	local parent = classes[1]
	if parent == nil then
		parent = Object
	end
	getmetatable(class).__class.parent = parent
	return class
end

return Class
