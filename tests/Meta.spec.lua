--- Tests for the @{Meta} function.

return function()
	local module = game:GetService("ReplicatedStorage").Draft
	local Meta = require(module.Meta)

	local function proxy(name, parent)
		local proxy = {}
		local meta = {}
		local class = {}
		setmetatable(proxy, meta)
		proxy.__meta = meta
		meta.__class = class
		class.name = name
		class.parent = parent
		class.implementing = {}
		class.interface = {}
		return proxy
	end

	describe("__index", function()
		it("should error when a class has an interface method", function()
			local A = proxy("A")
			A.__meta.__index = Meta.__index
			table.insert(A.__meta.__class.interface, "Test")
			expect(function()
				A:Test()
			end).to.throw("Abstract method 'Test' of 'A' must be overridden in the first concrete subclass. Called directly from 'A'.")
		end)

		it("should error when a class has an inherited interface method", function()
			local A = proxy("A")
			A.__meta.__index = Meta.__index
			table.insert(A.__meta.__class.interface, "Test")
			local B = proxy("B")
			B.__meta.__index = Meta.__index
			table.insert(B.__meta.__class.implementing, A)
			expect(function()
				B:Test()
			end).to.throw("Abstract method 'Test' of 'A' must be overridden in the first concrete subclass. Called directly from 'B'.")
		end)

		it("should error when a class has an inherited interface method from an ancestor", function()
			local A = proxy("A")
			A.__meta.__index = Meta.__index
			table.insert(A.__meta.__class.interface, "Test")
			local B = proxy("B")
			B.__meta.__index = Meta.__index
			table.insert(B.__meta.__class.implementing, A)
			local C = proxy("C")
			C.__meta.__index = Meta.__index
			table.insert(C.__meta.__class.implementing, B)
			expect(function()
				C:Test()
			end).to.throw("Abstract method 'Test' of 'A' must be overridden in the first concrete subclass. Called directly from 'C'.")
		end)

		it("should return nil when a member doesn't exist", function()
			local A = proxy("A")
			A.__meta.__index = Meta.__index
			expect(A.Test).never.to.be.ok()
		end)

		it("should call the method of a parent", function()
			local A = proxy("A")
			local called = false
			A.__meta.__index = Meta.__index
			function A:Test()
				called = true
			end
			local B = proxy("B", A)
			B.__meta.__index = Meta.__index
			expect(called).to.equal(false)
			B:Test()
			expect(called).to.equal(true)
		end)

		it("should call the method of an ancestor", function()
			local A = proxy("A")
			local called = false
			A.__meta.__index = Meta.__index
			function A:Test()
				called = true
			end
			local B = proxy("B", A)
			B.__meta.__index = Meta.__index
			local C = proxy("C", B)
			C.__meta.__index = Meta.__index
			expect(called).to.equal(false)
			C:Test()
			expect(called).to.equal(true)
		end)

		it("should call the method of a parent on itself", function()
			local A = proxy("A")
			A.__meta.__index = Meta.__index
			function A:Test()
				self.called = true
			end
			local B = proxy("B", A)
			B.__meta.__index = Meta.__index
			B.called = false
			expect(B.called).to.equal(false)
			B:Test()
			expect(B.called).to.equal(true)
		end)

		it("should call the method of an ancestor on itself", function()
			local A = proxy("A")
			A.__meta.__index = Meta.__index
			function A:Test()
				self.called = true
			end
			local B = proxy("C", A)
			B.__meta.__index = Meta.__index
			local C = proxy("C", B)
			C.__meta.__index = Meta.__index
			C.called = false
			expect(C.called).to.equal(false)
			C:Test()
			expect(C.called).to.equal(true)
		end)

		describe("interface", function()
			it("should present the 'interface' method", function()
				local A = proxy("A")
				A.__meta.__index = Meta.__index
				expect(A.interface).to.be.a("function")
			end)

			it("should allow adding interfaces", function()
				local A = proxy("A")
				A.__meta.__index = Meta.__index
				A:interface("Test")
				expect(#A.__meta.__class.interface).to.equal(1)
				expect(A.__meta.__class.interface[1]).to.equal("Test")
			end)

			it("should allow adding multiple interfaces", function()
				local A = proxy("A")
				A.__meta.__index = Meta.__index
				A:interface("Test1")
				A:interface("Test2")
				A:interface("Test3")
				expect(#A.__meta.__class.interface).to.equal(3)
				expect(A.__meta.__class.interface[1]).to.equal("Test1")
				expect(A.__meta.__class.interface[2]).to.equal("Test2")
				expect(A.__meta.__class.interface[3]).to.equal("Test3")
			end)

			it("should allow adding multiple interfaces at once", function()
				local A = proxy("A")
				A.__meta.__index = Meta.__index
				A:interface("Test1", "Test2", "Test3")
				expect(#A.__meta.__class.interface).to.equal(3)
				expect(A.__meta.__class.interface[1]).to.equal("Test1")
				expect(A.__meta.__class.interface[2]).to.equal("Test2")
				expect(A.__meta.__class.interface[3]).to.equal("Test3")
			end)
		end)
	end)

	describe("__tostring", function()
		it("should call the 'ToString' method", function()
			local A = proxy("A")
			local called = false
			A.__meta.__tostring = Meta.__tostring
			function A:ToString()
				called = true
				return ""
			end
			expect(called).to.equal(false)
			tostring(A)
			expect(called).to.equal(true)
		end)

		it("should pass the table to the 'ToString' method", function()
			local A = proxy("A")
			A.__meta.__tostring = Meta.__tostring
			function A:ToString()
				self.__meta.__tostring = nil
				expect(self).to.equal(A)
				return ""
			end
			tostring(A)
		end)
	end)

	describe("__call", function()
		it("should call the 'operatorCall' method", function()
			local A = proxy("A")
			local called = false
			A.__meta.__call = Meta.__call
			function A:operatorCall()
				called = true
			end
			expect(called).to.equal(false)
			A()
			expect(called).to.equal(true)
		end)

		it("should pass the table to the 'operatorCall' method", function()
			local A = proxy("A")
			A.__meta.__call = Meta.__call
			function A:operatorCall()
				expect(self).to.equal(A)
			end
			A()
		end)
	end)

	describe("__unm", function()
		it("should call the 'operatorUnm' method", function()
			local A = proxy("A")
			local called = false
			A.__meta.__unm = Meta.__unm
			function A:operatorUnm()
				called = true
			end
			expect(called).to.equal(false)
			A = -A
			expect(called).to.equal(true)
		end)

		it("should pass the table to the 'operatorUnm' method", function()
			local A = proxy("A")
			A.__meta.__unm = Meta.__unm
			function A:operatorUnm()
				expect(self).to.equal(A)
			end
			A = -A
		end)
	end)

	describe("__add", function()
		it("should call the 'operatorAdd' method", function()
			local A = proxy("A")
			local called = false
			A.__meta.__add = Meta.__add
			function A:operatorAdd()
				called = true
			end
			expect(called).to.equal(false)
			A = A + A
			expect(called).to.equal(true)
		end)

		it("should pass the tables to the 'operatorAdd' method", function()
			local A = proxy("A")
			A.__meta.__add = Meta.__add
			function A:operatorAdd(other)
				expect(self).to.equal(A)
				expect(other).to.equal(A)
			end
			A = A + A
		end)

		it("should pass the operands to the 'operatorAdd' method in order", function()
			local A = proxy("A")
			A.__meta.__add = Meta.__add
			function A:operatorAdd(other)
				expect(self).to.equal(A)
				expect(other).to.equal(1)
			end
			A = A + 1
		end)

		it("should pass the first operand as the first argument of the 'operatorAdd' method", function()
			local A = proxy("A")
			A.__meta.__add = Meta.__add
			function A:operatorAdd(other)
				expect(self).to.equal(1)
				expect(other).to.equal(A)
			end
			A = 1 + A
		end)
	end)

	describe("__sub", function()
		it("should call the 'operatorSub' method", function()
			local A = proxy("A")
			local called = false
			A.__meta.__sub = Meta.__sub
			function A:operatorSub()
				called = true
			end
			expect(called).to.equal(false)
			A = A - A
			expect(called).to.equal(true)
		end)

		it("should pass the tables to the 'operatorSub' method", function()
			local A = proxy("A")
			A.__meta.__sub = Meta.__sub
			function A:operatorSub(other)
				expect(self).to.equal(A)
				expect(other).to.equal(A)
			end
			A = A - A
		end)

		it("should pass the operands to the 'operatorSub' method in order", function()
			local A = proxy("A")
			A.__meta.__sub = Meta.__sub
			function A:operatorSub(other)
				expect(self).to.equal(A)
				expect(other).to.equal(1)
			end
			A = A - 1
		end)

		it("should pass the first operand as the first argument of the 'operatorSub' method", function()
			local A = proxy("A")
			A.__meta.__sub = Meta.__sub
			function A:operatorSub(other)
				expect(self).to.equal(1)
				expect(other).to.equal(A)
			end
			A = 1 - A
		end)
	end)

	describe("__mul", function()
		it("should call the 'operatorMul' method", function()
			local A = proxy("A")
			local called = false
			A.__meta.__mul = Meta.__mul
			function A:operatorMul()
				called = true
			end
			expect(called).to.equal(false)
			A = A * A
			expect(called).to.equal(true)
		end)

		it("should pass the tables to the 'operatorMul' method", function()
			local A = proxy("A")
			A.__meta.__mul = Meta.__mul
			function A:operatorMul(other)
				expect(self).to.equal(A)
				expect(other).to.equal(A)
			end
			A = A * A
		end)

		it("should pass the operands to the 'operatorMul' method in order", function()
			local A = proxy("A")
			A.__meta.__mul = Meta.__mul
			function A:operatorMul(other)
				expect(self).to.equal(A)
				expect(other).to.equal(1)
			end
			A = A * 1
		end)

		it("should pass the first operand as the first argument of the 'operatorMul' method", function()
			local A = proxy("A")
			A.__meta.__mul = Meta.__mul
			function A:operatorMul(other)
				expect(self).to.equal(1)
				expect(other).to.equal(A)
			end
			A = 1 * A
		end)
	end)

	describe("__div", function()
		it("should call the 'operatorDiv' method", function()
			local A = proxy("A")
			local called = false
			A.__meta.__div = Meta.__div
			function A:operatorDiv()
				called = true
			end
			expect(called).to.equal(false)
			A = A / A
			expect(called).to.equal(true)
		end)

		it("should pass the tables to the 'operatorDiv' method", function()
			local A = proxy("A")
			A.__meta.__div = Meta.__div
			function A:operatorDiv(other)
				expect(self).to.equal(A)
				expect(other).to.equal(A)
			end
			A = A / A
		end)

		it("should pass the operands to the 'operatorDiv' method in order", function()
			local A = proxy("A")
			A.__meta.__div = Meta.__div
			function A:operatorDiv(other)
				expect(self).to.equal(A)
				expect(other).to.equal(1)
			end
			A = A / 1
		end)

		it("should pass the first operand as the first argument of the 'operatorDiv' method", function()
			local A = proxy("A")
			A.__meta.__div = Meta.__div
			function A:operatorDiv(other)
				expect(self).to.equal(1)
				expect(other).to.equal(A)
			end
			A = 1 / A
		end)
	end)

	describe("__mod", function()
		it("should call the 'operatorMod' method", function()
			local A = proxy("A")
			local called = false
			A.__meta.__mod = Meta.__mod
			function A:operatorMod()
				called = true
			end
			expect(called).to.equal(false)
			A = A % A
			expect(called).to.equal(true)
		end)

		it("should pass the tables to the 'operatorMod' method", function()
			local A = proxy("A")
			A.__meta.__mod = Meta.__mod
			function A:operatorMod(other)
				expect(self).to.equal(A)
				expect(other).to.equal(A)
			end
			A = A % A
		end)

		it("should pass the operands to the 'operatorMod' method in order", function()
			local A = proxy("A")
			A.__meta.__mod = Meta.__mod
			function A:operatorMod(other)
				expect(self).to.equal(A)
				expect(other).to.equal(1)
			end
			A = A % 1
		end)

		it("should pass the first operand as the first argument of the 'operatorMod' method", function()
			local A = proxy("A")
			A.__meta.__mod = Meta.__mod
			function A:operatorMod(other)
				expect(self).to.equal(1)
				expect(other).to.equal(A)
			end
			A = 1 % A
		end)
	end)

	describe("__pow", function()
		it("should call the 'operatorPow' method", function()
			local A = proxy("A")
			local called = false
			A.__meta.__pow = Meta.__pow
			function A:operatorPow()
				called = true
			end
			expect(called).to.equal(false)
			A = A ^ A
			expect(called).to.equal(true)
		end)

		it("should pass the tables to the 'operatorPow' method", function()
			local A = proxy("A")
			A.__meta.__pow = Meta.__pow
			function A:operatorPow(other)
				expect(self).to.equal(A)
				expect(other).to.equal(A)
			end
			A = A ^ A
		end)

		it("should pass the operands to the 'operatorPow' method in order", function()
			local A = proxy("A")
			A.__meta.__pow = Meta.__pow
			function A:operatorPow(other)
				expect(self).to.equal(A)
				expect(other).to.equal(1)
			end
			A = A ^ 1
		end)

		it("should pass the first operand as the first argument of the 'operatorPow' method", function()
			local A = proxy("A")
			A.__meta.__pow = Meta.__pow
			function A:operatorPow(other)
				expect(self).to.equal(1)
				expect(other).to.equal(A)
			end
			A = 1 ^ A
		end)
	end)

	describe("__concat", function()
		it("should call the 'operatorConcat' method", function()
			local A = proxy("A")
			local called = false
			A.__meta.__concat = Meta.__concat
			function A:operatorConcat()
				called = true
			end
			expect(called).to.equal(false)
			A = A .. A
			expect(called).to.equal(true)
		end)

		it("should pass the tables to the 'operatorConcat' method", function()
			local A = proxy("A")
			A.__meta.__concat = Meta.__concat
			function A:operatorConcat(other)
				expect(self).to.equal(A)
				expect(other).to.equal(A)
			end
			A = A .. A
		end)

		it("should pass the operands to the 'operatorConcat' method in order", function()
			local A = proxy("A")
			A.__meta.__concat = Meta.__concat
			function A:operatorConcat(other)
				expect(self).to.equal(A)
				expect(other).to.equal(1)
			end
			A = A .. 1
		end)

		it("should pass the first operand as the first argument of the 'operatorConcat' method", function()
			local A = proxy("A")
			A.__meta.__concat = Meta.__concat
			function A:operatorConcat(other)
				expect(self).to.equal(1)
				expect(other).to.equal(A)
			end
			A = 1 .. A
		end)
	end)

	describe("__eq", function()
		it("should call the 'operatorEq' method", function()
			local A = proxy("A")
			local called = false
			A.__meta.__eq = Meta.__eq
			local B = proxy("B")
			B.__meta.__eq = Meta.__eq

			function A:operatorEq()
				called = true
			end

			expect(called).to.equal(false)
			A = A == B
			expect(called).to.equal(true)
		end)

		it("should pass the tables to the 'operatorEq' method", function()
			local A = proxy("A")
			A.__meta.__eq = Meta.__eq
			local B = proxy("B")
			B.__meta.__eq = Meta.__eq

			function A:operatorEq(other)
				self.__meta.__eq = nil
				other.__meta.__eq = nil
				expect(self).to.equal(A)
				expect(other).to.equal(B)
			end

			B.operatorEq = A.operatorEq
			A = A == B
		end)

		it("should pass the operands to the 'operatorEq' method in order", function()
			local A = proxy("A")
			A.__meta.__eq = Meta.__eq
			local B = proxy("B")
			B.__meta.__eq = Meta.__eq

			function A:operatorEq(other)
				self.__meta.__eq = nil
				other.__meta.__eq = nil
				expect(self).to.equal(B)
				expect(other).to.equal(A)
			end

			B.operatorEq = A.operatorEq
			A = B == A
		end)
	end)

	describe("__lt", function()
		it("should call the 'operatorLT' method", function()
			local A = proxy("A")
			local called = false
			A.__meta.__lt = Meta.__lt
			local B = proxy("B")
			B.__meta.__lt = Meta.__lt

			function A:operatorLT()
				called = true
			end

			expect(called).to.equal(false)
			A = A < B
			expect(called).to.equal(true)
		end)

		it("should pass the tables to the 'operatorLT' method", function()
			local A = proxy("A")
			A.__meta.__lt = Meta.__lt
			local B = proxy("B")
			B.__meta.__lt = Meta.__lt

			function A:operatorLT(other)
				expect(self).to.equal(A)
				expect(other).to.equal(B)
			end

			B.operatorLT = A.operatorLT
			A = A < B
		end)

		it("should pass the operands to the 'operatorLT' method in order", function()
			local A = proxy("A")
			A.__meta.__lt = Meta.__lt
			local B = proxy("B")
			B.__meta.__lt = Meta.__lt

			function A:operatorLT(other)
				expect(self).to.equal(B)
				expect(other).to.equal(A)
			end

			B.operatorLT = A.operatorLT
			A = B < A
		end)
	end)

	describe("__le", function()
		it("should call the 'operatorLE' method", function()
			local A = proxy("A")
			local called = false
			A.__meta.__le = Meta.__le
			local B = proxy("B")
			B.__meta.__le = Meta.__le

			function A:operatorLE()
				called = true
			end

			expect(called).to.equal(false)
			A = A <= B
			expect(called).to.equal(true)
		end)

		it("should pass the tables to the 'operatorLE' method", function()
			local A = proxy("A")
			A.__meta.__le = Meta.__le
			local B = proxy("B")
			B.__meta.__le = Meta.__le

			function A:operatorLE(other)
				expect(self).to.equal(A)
				expect(other).to.equal(B)
			end

			B.operatorLE = A.operatorLE
			A = A <= B
		end)

		it("should pass the operands to the 'operatorLE' method in order", function()
			local A = proxy("A")
			A.__meta.__le = Meta.__le
			local B = proxy("B")
			B.__meta.__le = Meta.__le

			function A:operatorLE(other)
				expect(self).to.equal(B)
				expect(other).to.equal(A)
			end

			B.operatorLE = A.operatorLE
			A = B <= A
		end)
	end)
end
