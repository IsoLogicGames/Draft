--- The root class object.
-- The ancestor of all classes. Provides basic common functionality.
--
-- @module Object

local module = script.Parent
local Meta = require(module.Meta)

local ErrorAncestry = "Cannot determine if type '%s' is in ancestry of '%s'."
local ErrorAncestryClass = "Cannot determine if non-class is in ancestry of '%s'."
local ErrorSuperName = "Cannot call parent method with function name of type '%s'."
local ErrorSuperAncestor = "Cannot call method '%s' of parent of class '%s'. No method exists in ancestry."
local ErrorCast = "Cannot cast to class of type '%s'."
local ErrorCastClass = "Cannot cast to non-class."
local ErrorCastAncestor = "Cannot cast to class '%s'. It is not an ancestor of '%s'."

local function setMeta(object)
	local meta = {}
	local class = {}
	setmetatable(object, meta)
	object.__meta = meta
	for key, value in pairs(Meta) do
		meta[key] = value
	end
	meta.__class = class
	class.interface = {}
	class.implementing = {}
	return class
end

local function getClass(object)
	local meta = getmetatable(object)
	if type(meta) ~= "table" then
		error()
	end
	local class = meta.__class
	if type(class) ~= "table" then
		error()
	end
	return class
end

local function inAncestry(object, ancestor)
	local class = getClass(object)
	if object == ancestor or class.name == ancestor then
		return object
	end

	if class.parent ~= nil then
		local classObject = inAncestry(class.parent, ancestor)
		if classObject ~= nil then
			return classObject
		end
	end
	for _, interface in ipairs(class.implementing) do
		local interfaceObject = inAncestry(interface, ancestor)
		if interfaceObject then
			return interfaceObject
		end
	end
	return nil
end

local Object = {}
setMeta(Object).name = "Object"

function Object.new()
	return Object:instance()
end

function Object:instance()
	local selfClass = getClass(self)
	local object = {}
	local class = setMeta(object)
	class.name = selfClass.name
	class.parent = self
	return object
end

function Object:super(method, ...)
	local methodType = type(method)
	if methodType ~= "string" then
		error(string.format(ErrorSuperName, methodType))
	end
	local class = getClass(self)
	local ancestor = class.parent
	while ancestor ~= nil and ancestor[method] == self[method] do
		class = getClass(ancestor)
		ancestor = class.parent
	end
	if ancestor == nil then
		error(string.format(ErrorSuperAncestor, method, self:ToString()))
	end
	if type(ancestor[method]) ~= "function" then
		error()
	end
	return ancestor[method](self, ...)
end

function Object:As(class)
	local typeClass = type(class)
	local actualClass
	if typeClass ~= "string" then
		if typeClass ~= "table" then
			error(string.format(ErrorCast, typeClass))
		end
		local meta = getmetatable(class)
		if meta == nil or meta.__class == nil then
			error(string.format(ErrorCastClass))
		end
		actualClass = class
	else
		actualClass = inAncestry(self, class)
	end
	if actualClass == nil then
		error(string.format(ErrorCastAncestor, class, self:ToString()))
	end
	local classClass = getClass(actualClass)
	local selfMeta = getmetatable(self)
	if type(selfMeta) ~= "table" then
		error()
	end
	local as = {}
	local asClass = setMeta(as)
	local meta = getmetatable(as)

	meta.__newindex = function(_, key, value)
		self[key] = value
	end

	asClass.name = classClass.name
	if classClass.parent == nil then
		local object = Object:instance()
		asClass.parent = object
		table.insert(object.__meta.__class.implementing, actualClass)
	else
		asClass.parent = actualClass
	end
	asClass.instance = self
	return as
end

function Object:Type()
	return getClass(self).parent
end

function Object:Equals(other)
	local metaL, metaR, __eqL, __eqR
	local checkL = false
	local checkR = false
	if type(self) == "table" then
		metaL = getmetatable(self)
		checkL = type(metaL) == "table"
		if checkL then
			__eqL = metaL.__eq
			metaL.__eq = nil
		end
	end
	if type(other) == "table" then
		metaR = getmetatable(other)
		checkR = type(metaR) == "table"
		if checkR then
			__eqR = metaR.__eq
			metaR.__eq = nil
		end
	end
	local eq = self == other
	if checkL then
		metaL.__eq = __eqL
	end
	if checkR then
		metaR.__eq = __eqR
	end
	return eq
end

function Object:operatorEq(other, ...)
	local eq = self.Equals or other.Equals
	return eq(self, other, ...)
end

function Object:IsA(ancestor)
	local typeAncestor = type(ancestor)
	if typeAncestor ~= "string" then
		if typeAncestor ~= "table" then
			error(string.format(ErrorAncestry, typeAncestor, self:ToString()))
		end
		local meta = getmetatable(ancestor)
		if meta == nil or meta.__class == nil then
			error(string.format(ErrorAncestryClass, self:ToString()))
		end
	end
	return inAncestry(self, ancestor) ~= nil
end

function Object:ToString()
	local name = getClass(self).name
	local typeName = type(name)
	if typeName ~= "string" then
		error()
	end
	return name
end

return Object
