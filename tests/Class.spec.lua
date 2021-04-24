--- Tests for the @{Class} function.

return function()
	local module = game:GetService("ReplicatedStorage").Draft
	local Class = require(module.Class)
	local Interface = require(module.Interface)
	local Meta = require(module.Meta)
	local Object = require(module.Object)

	describe("Function", function()
		it("should be a function", function()
			expect(Class).to.be.a("function")
		end)

		it("should error when name is not a string", function()
			expect(function()
				Class()
			end).to.throw("Cannot create a class with name of type 'nil'.")
			expect(function()
				Class(true)
			end).to.throw("Cannot create a class with name of type 'boolean'.")
			expect(function()
				Class(1)
			end).to.throw("Cannot create a class with name of type 'number'.")
			expect(function()
				Class({})
			end).to.throw("Cannot create a class with name of type 'table'.")
			expect(function()
				Class(function()
				end)
			end).to.throw("Cannot create a class with name of type 'function'.")
			expect(function()
				Class(Instance.new("Folder"))
			end).to.throw("Cannot create a class with name of type 'userdata'.")
			expect(function()
				Class(coroutine.create(function()
				end))
			end).to.throw("Cannot create a class with name of type 'thread'.")
		end)

		it("should return a table", function()
			expect(Class("Test")).to.be.a("table")
		end)
	end)

	describe("__meta", function()
		it("should return a table with a '__meta' metatable member", function()
			local test = Class("Test")
			expect(test.__meta).to.be.a("table")
			expect(getmetatable(test)).to.equal(test.__meta)
		end)

		it("should have all members of 'Meta'", function()
			local meta = Class("Test").__meta
			for key, value in pairs(Meta) do
				expect(meta[key]).to.equal(value)
			end
		end)

		it("should have a '__class' metatable", function()
			local meta = Class("Test").__meta
			expect(meta.__class).to.be.a("table")
		end)

		it("should have a '__class' name", function()
			local meta = Class("Test").__meta
			expect(meta.__class.name).to.equal("Test")
		end)

		it("should have a '__class' parent", function()
			local meta = Class("Test").__meta
			expect(meta.__class.parent).to.equal(Object)
		end)

		it("should have a '__class' implementing table", function()
			local meta = Class("Test").__meta
			expect(meta.__class.implementing).to.be.a("table")
		end)

		it("should have a '__class' interface table", function()
			local meta = Class("Test").__meta
			expect(meta.__class.interface).to.be.a("table")
		end)
	end)

	describe("Inheritance", function()
		it("should error when given a non-table", function()
			expect(function()
				Class("Test", true)
			end).to.throw("Cannot create a class inheriting from parent of type 'boolean'.")
			expect(function()
				Class("Test", 1)
			end).to.throw("Cannot create a class inheriting from parent of type 'number'.")
			expect(function()
				Class("Test", "string")
			end).to.throw("Cannot create a class inheriting from parent of type 'string'.")
			expect(function()
				Class("Test", function()
				end)
			end).to.throw("Cannot create a class inheriting from parent of type 'function'.")
			expect(function()
				Class("Test", Instance.new("Folder"))
			end).to.throw("Cannot create a class inheriting from parent of type 'userdata'.")
			expect(function()
				Class("Test", coroutine.create(function()
				end))
			end).to.throw("Cannot create a class inheriting from parent of type 'thread'.")
		end)

		it("should error when parent has no '__class' metatable", function()
			expect(function()
				Class("Test", {})
			end).to.throw("Cannot create a class inheriting from non-class or non-interface.")
		end)

		it("should have the parent Object when not explicitly given", function()
			local A = Class("A")
			expect(A.__meta.__class.parent).to.equal(Object)
		end)

		it("should have the parent given as the parent", function()
			local A = Class("A")
			local B = Class("B", A)
			expect(B.__meta.__class.parent).to.equal(A)
		end)

		it("should inherit members from the parent", function()
			local A = Class("A")

			function A:Test()
			end

			local B = Class("B", A)
			expect(B.Test).to.be.a("function")
		end)

		it("should error when given multiple non-interface parents", function()
			local A = Class("A")
			local B = Class("B")
			expect(function()
				Class("C", A, B)
			end).to.throw("Cannot create a class inheriting from more than one non-interface parent.")
		end)

		it("should implement interfaces when inheriting a class", function()
			local A = Interface("A")
			local B = Class("B")
			local C = Class("C", B, A)
			expect(C.__meta.__class.parent).to.equal(B)
			expect(#C.__meta.__class.implementing).to.equal(1)
			expect(C.__meta.__class.implementing[1]).to.equal(A)
		end)
	end)
end
