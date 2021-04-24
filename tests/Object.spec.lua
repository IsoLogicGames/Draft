--- Tests for the @{Meta} function.

return function()
	local module = game:GetService("ReplicatedStorage").Draft
	local Object = require(module.Object)
	local Class = require(module.Class)
	local Interface = require(module.Interface)

	describe("Constructor", function()
		it("should be able to be instantiated", function()
			local object = Object.new()
			expect(object).to.be.ok()
		end)

		it("should be an 'Object' instance", function()
			local object = Object.new()
			expect(object:Type()).to.equal(Object)
		end)
	end)

	describe("instance()", function()
		it("should create an 'Object'", function()
			local object = Object:instance()
			expect(object:Type()).to.equal(Object)
		end)

		it("should create an inherited class", function()
			local A = Class("A")
			local object = A:instance()
			expect(object:Type()).to.equal(A)
		end)

		it("should have a class name of 'Object'", function()
			local object = Object:instance()
			expect(object.__meta.__class.name).to.equal("Object")
		end)

		it("should have a class instance of 'Object'", function()
			local object = Object:instance()
			expect(object.__meta.__class.instance).to.equal(Object)
		end)

		it("should have no class parent", function()
			local object = Object:instance()
			expect(object.__meta.__class.parent).to.equal(nil)
		end)

		it("should have no class interfaces", function()
			local object = Object:instance()
			expect(#object.__meta.__class.implementing).to.equal(0)
		end)

		it("should have no class abstract methods", function()
			local object = Object:instance()
			expect(#object.__meta.__class.interface).to.equal(0)
		end)
	end)

	describe("super()", function()
		it("should error if the function name is not a string", function()
			local object = Object.new()
			expect(function()
				object:super()
			end).to.throw("Cannot call parent method with function name of type 'nil'.")
			expect(function()
				object:super(true)
			end).to.throw("Cannot call parent method with function name of type 'boolean'.")
			expect(function()
				object:super(1)
			end).to.throw("Cannot call parent method with function name of type 'number'.")
			expect(function()
				object:super({})
			end).to.throw("Cannot call parent method with function name of type 'table'.")
			expect(function()
				object:super(function()
				end)
			end).to.throw("Cannot call parent method with function name of type 'function'.")
			expect(function()
				object:super(Instance.new("Folder"))
			end).to.throw("Cannot call parent method with function name of type 'userdata'.")
			expect(function()
				object:super(coroutine.create(function()
				end))
			end).to.throw("Cannot call parent method with function name of type 'thread'.")
		end)

		it("should error if no parent exists", function()
			local object = Object.new()
			expect(function()
				object:super("Test")
			end).to.throw("Cannot call method 'Test' of parent of class 'Object'. No method exists in ancestry.")
		end)

		it("should error if the method does not exist in the ancestry", function()
			local A = Class("A")
			local B = Class("B", A)
			local a = A:instance()
			local b = B:instance()
			expect(function()
				a:super("Test")
			end).to.throw("Cannot call super method 'Test' of class 'A'. No method exists in ancestry.")
			expect(function()
				b:super("Test")
			end).to.throw("Cannot call super method 'Test' of class 'B'. No method exists in ancestry.")
		end)

		it("should call the method of its parent", function()
			local A = Class("A")
			local called = false

			function A:Test()
				called = true
			end

			local B = Class("B", A)
			local b = B:instance()
			b:super("Test")
			expect(called).to.equal(true)
		end)

		it("should should not call the method of its class", function()
			local A = Class("A")

			function A:Test()
			end

			local B = Class("B", A)
			local notCalled = false

			function B:Test()
				notCalled = true
			end

			local b = B:instance()
			b:super("Test")
			expect(notCalled).to.equal(false)
		end)

		it("should call the method of its ancestor", function()
			local A = Class("A")
			local called = false

			function A:Test()
				called = true
			end

			local B = Class("B", A)
			local C = Class("C", B)
			local c = C:instance()
			c:super("Test")
			expect(called).to.equal(true)
		end)

		it("should call the first method in its ancestry", function()
			local A = Class("A")
			local notCalled = false

			function A:Test()
				notCalled = true
			end

			local B = Class("B", A)
			local called = false

			function B:Test()
				called = true
			end

			local C = Class("C", B)
			local c = C:instance()
			c:super("Test")
			expect(notCalled).to.equal(false)
			expect(called).to.equal(true)
		end)

		it("should chain calls", function()
			local A = Class("A")
			local called = false

			function A:Test()
				called = true
			end

			local B = Class("B", A)

			function B:Test()
				self:super("Test")
			end

			local C = Class("C", B)
			local c = C:instance()
			c:super("Test")
			expect(called).to.equal(true)
		end)
	end)

	describe("As()", function()
		it("should error when the class is not a string or table", function()
			local object = Object.new()
			expect(function()
				object:As()
			end).to.throw("Cannot cast to class of type 'nil'.")
			expect(function()
				object:As(true)
			end).to.throw("Cannot cast to class of type 'boolean'.")
			expect(function()
				object:As(1)
			end).to.throw("Cannot cast to class of type 'number'.")
			expect(function()
				object:As(function()
				end)
			end).to.throw("Cannot cast to class of type 'function'.")
			expect(function()
				object:As(Instance.new("Folder"))
			end).to.throw("Cannot cast to class of type 'userdata'.")
			expect(function()
				object:As(coroutine.create(function()
				end))
			end).to.throw("Cannot cast to class of type 'thread'.")
		end)

		it("should error when the class is not instantiated", function()
			expect(function()
				Object:As("Test")
			end).to.throw("Cannot cast uninstantiated class 'Object'")
		end)

		it("should error when the table provided is not a class", function()
			local object = Object.new()
			expect(function()
				object:As("Test")
			end).to.throw("Cannot cast to non-class.")
		end)

		it("should error when the class is not in the ancestry", function()
			local object = Object.new()
			expect(function()
				object:As("Test")
			end).to.throw("Cannot cast to class 'Test'. 'Test' is not an ancestor of 'Object'.")
		end)

		it("should cast to a parent", function()
			local A = Class("A")
			local B = Class("B", A)
			local b = B:instance()
			local a = b:As(A)
			expect(b:Type()).to.equal(B)
			expect(a:Type()).to.equal(A)
		end)

		it("should cast to an ancestor", function()
			local A = Class("A")
			local B = Class("B", A)
			local C = Class("C", B)
			local c = C:instance()
			local a = c:As(A)
			expect(c:Type()).to.equal(C)
			expect(a:Type()).to.equal(A)
		end)

		it("should cast to an interface", function()
			local A = Interface("A")
			local B = Class("B", A)
			local b = B:instance()
			local a = b:As(A)
			expect(b:Type()).to.equal(B)
			expect(a:Type()).to.equal(A)
		end)

		it("should cast by name", function()
			local A = Class("A")
			local B = Class("B", A)
			local b = B:instance()
			local a = b:As("A")
			expect(b:Type()).to.equal(B)
			expect(a:Type()).to.equal(A)
		end)

		it("should call methods polymorphically", function()
			local A = Class("A")
			local notCalled = false

			function A:Test()
				notCalled = true
			end

			local B = Class("B", A)
			local called = false

			function B:Test()
				called = true
			end

			local b = B:instance()
			local a = b:As(A)
			a:Test()
			expect(notCalled).to.equal(false)
			expect(called).to.equal(true)
		end)

		it("should call interface methods polymorphically", function()
			local A = Interface("A")

			A:interface("Test")

			local B = Class("B", A)
			local called = false

			function B:Test()
				called = true
			end

			local b = B:instance()
			local a = b:As(A)
			a:Test()
			expect(called).to.equal(true)
		end)

		it("should error when calling methods that don't exist in the cast class", function()
			local A = Class("A")
			local B = Class("B", A)

			function B:Test()
			end

			local b = B:instance()
			local a = b:As(A)
			expect(function()
				a:Test()
			end).to.throw("No member 'Test' exists in 'A'.")
		end)
	end)

	describe("Type()", function()
		it("should return the class", function()
			local A = Class("A")
			local a = A:instance()
			expect(a:Type()).to.equal(A)
		end)
	end)

	describe("Equals()", function()
		it("should return true if the tables are the same", function()
			expect(Object:Equals(Object)).to.equal(true)
		end)

		it("should false if the tables are different", function()
			expect(Object:Equals({})).to.equal(false)
		end)
	end)

	describe("operatorEq", function()
		it("should call 'Equals'", function()
			local A = Class("A")
			local called = false

			function A:Equals()
				called = true
			end

			local B = Class("B")
			local a = A:instance()
			local b = B:instance()
			a = a == b
			expect(called).to.equal(true)
		end)
	end)

	describe("IsA()", function()
		it("should error when the class is not a string or table", function()
			local object = Object.new()
			expect(function()
				object:IsA()
			end).to.throw("Cannot determine if type 'nil' is in ancestry of 'Object'.")
			expect(function()
				object:IsA(true)
			end).to.throw("Cannot determine if type 'boolean' is in ancestry of 'Object'.")
			expect(function()
				object:IsA(1)
			end).to.throw("Cannot determine if type 'number' is in ancestry of 'Object'.")
			expect(function()
				object:IsA(function()
				end)
			end).to.throw("Cannot determine if type 'function' is in ancestry of 'Object'.")
			expect(function()
				object:IsA(Instance.new("Folder"))
			end).to.throw("Cannot determine if type 'userdata' is in ancestry of 'Object'.")
			expect(function()
				object:IsA(coroutine.create(function()
				end))
			end).to.throw("Cannot determine if type 'thread' is in ancestry of 'Object'.")
		end)

		it("should error if the table is not a class", function()
			local object = Object.new()
			expect(function()
				object:IsA({})
			end).to.throw("Cannot determine if non-class is in ancestry of 'Object'.")
		end)

		it("should return true on it actual class", function()
			local object = Object.new()
			expect(object:IsA(Object)).to.equal(true)
		end)

		it("should return true on its parent class", function()
			local A = Class("A")
			local B = Class("B", A)
			local b = B:instance()
			expect(b:IsA(A)).to.equal(true)
		end)

		it("should return true on an ancestor class", function()
			local A = Class("A")
			local B = Class("B", A)
			local C = Class("C", B)
			local c = C:instance()
			expect(c:IsA(A)).to.equal(true)
		end)

		it("should return accept a string", function()
			local object = Object.new()
			expect(object:IsA("Object")).to.equal(true)
		end)

		it("should return false when the class is not in its ancestry", function()
			local A = Class("A")
			local B = Class("B")
			local b = B:instance()
			expect(b:IsA(A)).to.equal(false)
		end)
	end)

	describe("ToString()", function()
		it("should return the name of the class", function()
			local A = Class("A")
			local B = Class("B")
			local object = Object.new()
			local a = A:instance()
			local b = B:instance()
			expect(object:ToString()).to.equal("Object")
			expect(a:ToString()).to.equal("A")
			expect(b:ToString()).to.equal("B")
		end)
	end)
end
