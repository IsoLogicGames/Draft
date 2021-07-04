--- Provides the Class function.
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

--- Ensures an object contains a class table.
-- Raises an error if there is a problem with the provided object.
--
-- @param class the object to check for a class table
-- @raise
-- * if class is not a table
-- * if class has no metatable
-- * if class has no class table
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

--- Separates a list of mixed classes and interfaces.
--
-- @param parents the list of classes and interfaces
-- @return a list of classes
-- @return a list of interfaces
-- @raise
-- * if a class or interface is not a table
-- * if a class or interface has no metatable
-- * if a class or interface has no class table
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

--- Creates a new class.
-- If no parent class is given the new class inherits from @{Object}.
--
-- @param name the name of the new class
-- @param[opt] ... up to one parent class and any number of implemented
-- @{Interface|interfaces}
-- @return the new class
-- @raise
-- * if the name is not a string
-- * if a class or interface is not a table
-- * if a class or interface has no metatable
-- * if a class or interface has no class table
-- * if multiple parent classes are given
-- @see Object
-- @see Interface
-- @usage
-- local MyInterface = Interface("MyInterface")
-- local MyClass = Class("MyClass")
-- local MySubClass = Class("MySubClass", MyClass)
-- local MyImplementingClass = Class("MyImplementingClass", MyClass, MyInterface)
-- @function Class
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
