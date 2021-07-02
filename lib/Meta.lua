--- The class metatable.
-- Provides a prototype metatable for use in classes.
--
-- @module Meta

local ErrorAbstract =
	"Abstract method '%s' of '%s' must be overridden in the first concrete subclass. Called directly from '%s'."
local ErrorMeta = "Inaccessible class in ancestry."
local ErrorClass = "Non-class in ancestry."
local ErrorInterfaceMeta = "Cannot add interface on inaccessible class."
local ErrorInterfaceClass = "Cannot add interface on non-class."

local ErrorCall = "No method exists to invoke class '%s'."
local ErrorUnm = "No method exists to negate class '%s'."
local ErrorAdd = "No method exists to add '%s' and '%s'."
local ErrorSub = "No method exists to subtract '%s' by '%s'."
local ErrorMul = "No method exists to multiply '%s' and '%s'."
local ErrorDiv = "No method exists to divide '%s' by '%s'."
local ErrorMod = "No method exists to reduce '%s' modulo '%s'."
local ErrorPow = "No method exists to raise '%s' to the '%s' power."
local ErrorConcat = "No method exists to concatenate '%s' and '%s'."
local ErrorLT = "No method exists to compare '%s' is less than '%s'."
local ErrorLE = "No method exists to compare '%s' is less than or equal to '%s'."

local Meta = {}

local function throw(message)
	return function()
		error(message)
	end
end

local function rootInstance(table)
	local meta = getmetatable(table)
	if type(meta) ~= "table" then
		return throw(ErrorMeta)
	end
	local class = meta.__class
	if type(class) ~= "table" then
		return throw(ErrorClass)
	end

	if class.instance ~= nil then
		local instance = rootInstance(class.instance)
		if instance ~= nil then
			return instance
		end
	end
	return class.instance
end

local function exists(table, key)
	local meta = getmetatable(table)
	if type(meta) ~= "table" then
		return throw(ErrorMeta)
	end

	local class = meta.__class
	if type(class) ~= "table" then
		return throw(ErrorClass)
	end

	do
		local index = meta.__index
		meta.__index = nil
		local rawkey = table[key]
		meta.__index = index
		if rawkey ~= nil then
			local instance = rootInstance(table)
			if type(instance) == "function" then
				return instance
			end
			if instance ~= nil then
				rawkey = instance[key]
			end
			return rawkey, table
		end
	end

	for _, method in ipairs(class.interface) do
		if method == key then
			return nil, table
		end
	end

	if class.parent ~= nil then
		local method, origin = exists(class.parent, key)
		if method ~= nil or origin ~= nil then
			local instance = rootInstance(table)
			if type(instance) == "function" then
				return instance
			end
			if instance ~= nil then
				method = instance[key]
			end
			return method, origin
		end
	end

	for _, interface in ipairs(class.implementing) do
		local _, origin = exists(interface, key)
		if origin ~= nil then
			return nil, origin
		end
	end
end

local function interface(self, ...)
	local meta = getmetatable(self)
	if type(meta) ~= "table" then
		error(ErrorInterfaceMeta)
	end
	local class = meta.__class
	if type(class) ~= "table" then
		error(ErrorInterfaceClass)
	end
	for _, method in pairs({ ... }) do
		table.insert(class.interface, method)
	end
end

local function leftOrRight(left, right, operator, errorString)
	if type(left) ~= "table" then
		if type(right[operator]) ~= "function" then
			if errorString ~= nil then
				error(string.format(errorString, tostring(left), tostring(right)))
			else
				return nil
			end
		end
		return right[operator](left, right)
	end
	if type(left[operator]) ~= "function" then
		if type(right) ~= "table" or type(right[operator]) ~= "function" then
			if errorString ~= nil then
				error(string.format(errorString, tostring(left), tostring(right)))
			else
				return nil
			end
		end
		return right[operator](left, right)
	end
	return left[operator](left, right)
end

function Meta.__index(table, key)
	if key == "interface" then
		return interface
	end
	local method, origin = exists(table, key)
	if method == nil and origin ~= nil then
		return throw(string.format(ErrorAbstract, key, getmetatable(origin).__class.name, getmetatable(table).__class.name))
	end
	return method
end

function Meta.__tostring(table)
	if type(table.ToString) ~= "function" then
		local meta = getmetatable(table)
		local check = type(meta) == "table"
		local __tostring
		if check then
			__tostring = meta.__tostring
			meta.__tostring = nil
		end
		local string = tostring(table)
		if check then
			meta.__tostring = __tostring
		end
		return string
	end
	return table:ToString()
end

function Meta.__call(table, ...)
	if type(table.operatorCall) ~= "function" then
		error(string.format(ErrorCall, table))
	end
	return table:operatorCall(...)
end

function Meta.__unm(table)
	if type(table.operatorUnm) ~= "function" then
		error(string.format(ErrorUnm, table))
	end
	return table:operatorUnm()
end

function Meta.__add(left, right)
	return leftOrRight(left, right, "operatorAdd", ErrorAdd)
end

function Meta.__sub(left, right)
	return leftOrRight(left, right, "operatorSub", ErrorSub)
end

function Meta.__mul(left, right)
	return leftOrRight(left, right, "operatorMul", ErrorMul)
end

function Meta.__div(left, right)
	return leftOrRight(left, right, "operatorDiv", ErrorDiv)
end

function Meta.__mod(left, right)
	return leftOrRight(left, right, "operatorMod", ErrorMod)
end

function Meta.__pow(left, right)
	return leftOrRight(left, right, "operatorPow", ErrorPow)
end

function Meta.__concat(left, right)
	return leftOrRight(left, right, "operatorConcat", ErrorConcat)
end

function Meta.__eq(left, right)
	local eq = leftOrRight(left, right, "operatorEq")
	if eq == nil then
		local metaL, metaR, __eqL, __eqR
		local checkL = false
		local checkR = false
		if type(left) == "table" then
			metaL = getmetatable(left)
			checkL = type(metaL) == "table"
			if checkL then
				__eqL = metaL.__eq
				metaL.__eq = nil
			end
		end
		if type(right) == "table" then
			metaR = getmetatable(right)
			checkR = type(metaR) == "table"
			if checkR then
				__eqR = metaR.__eq
				metaR.__eq = nil
			end
		end
		eq = left == right
		if checkL then
			metaL.__eq = __eqL
		end
		if checkR then
			metaR.__eq = __eqR
		end
	end
	return eq
end

function Meta.__lt(left, right)
	return leftOrRight(left, right, "operatorLT", ErrorLT)
end

function Meta.__le(left, right)
	return leftOrRight(left, right, "operatorLE", ErrorLE)
end

return Meta
