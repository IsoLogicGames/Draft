--- Tests for the @{Interface} function.

return function()
	local module = game:GetService("ReplicatedStorage").Draft
	local Interface = require(module.Interface)
	local Meta = require(module.Meta)
	local Object = require(module.Object)

	describe("Function", function()
		it("should be a function", function()
			expect(Interface).to.be.a("function")
		end)

		it("should error when name is not a string", function()
			expect(function()
				Interface()
			end).to.throw("Cannot create an interface with name of type 'nil'.")
			expect(function()
				Interface(true)
			end).to.throw("Cannot create an interface with name of type 'boolean'.")
			expect(function()
				Interface(1)
			end).to.throw("Cannot create an interface with name of type 'number'.")
			expect(function()
				Interface({})
			end).to.throw("Cannot create an interface with name of type 'table'.")
			expect(function()
				Interface(function()
				end)
			end).to.throw("Cannot create an interface with name of type 'function'.")
			expect(function()
				Interface(Instance.new("Folder"))
			end).to.throw("Cannot create an interface with name of type 'userdata'.")
			expect(function()
				Interface(coroutine.create(function()
				end))
			end).to.throw("Cannot create an interface with name of type 'thread'.")
		end)

		it("should return a table", function()
			expect(Interface("Test")).to.be.a("table")
		end)
	end)

	describe("__meta", function()
		it("should return a table with a '__meta' metatable member", function()
			local test = Interface("Test")
			expect(test.__meta).to.be.a("table")
			expect(getmetatable(test)).to.equal(test.__meta)
		end)

		it("should have all members of 'Meta'", function()
			local meta = Interface("Test").__meta
			for key, value in pairs(Meta) do
				expect(meta[key]).to.equal(value)
			end
		end)

		it("should have a '__class' metatable", function()
			local meta = Interface("Test").__meta
			expect(meta.__class).to.be.a("table")
		end)

		it("should have a '__class' name", function()
			local meta = Interface("Test").__meta
			expect(meta.__class.name).to.equal("Test")
		end)

		it("should not have a '__class' parent", function()
			local meta = Interface("Test").__meta
			expect(meta.__class.parent).to.equal(nil)
		end)

		it("should have a '__class' implementing table", function()
			local meta = Interface("Test").__meta
			expect(meta.__class.implementing).to.be.a("table")
		end)

		it("should have a '__class' interface table", function()
			local meta = Interface("Test").__meta
			expect(meta.__class.interface).to.be.a("table")
		end)
	end)

	describe("Inheritance", function()
		it("should error when given a non-table", function()
			expect(function()
				Interface("Test", true)
			end).to.throw("Cannot create an interface implementing a parent of type 'boolean'.")
			expect(function()
				Interface("Test", 1)
			end).to.throw("Cannot create an interface implementing a parent of type 'number'.")
			expect(function()
				Interface("Test", "string")
			end).to.throw("Cannot create an interface implementing a parent of type 'string'.")
			expect(function()
				Interface("Test", function()
				end)
			end).to.throw("Cannot create an interface implementing a parent of type 'function'.")
			expect(function()
				Interface("Test", Instance.new("Folder"))
			end).to.throw("Cannot create an interface implementing a parent of type 'userdata'.")
			expect(function()
				Interface("Test", coroutine.create(function()
				end))
			end).to.throw("Cannot create an interface implementing a parent of type 'thread'.")
		end)

		it("should error when parent has no metatable", function()
			expect(function()
				Interface("Test", {})
			end).to.throw("Cannot create an interface implementing an inaccessible class.")
		end)

		it("should error when parent has no '__class' metatable", function()
			local A = {}
			setmetatable(A, {})
			expect(function()
				Interface("Test", A)
			end).to.throw("Cannot create an interface implementing a non-interface.")
		end)

		it("should error when parent is a class", function()
			expect(function()
				Interface("Test", Object)
			end).to.throw("Cannot create an interface implementing a class.")
		end)

		it("should have no interfaces when not given one", function()
			local A = Interface("A")
			expect(#A.__meta.__class.implementing).to.equal(0)
		end)

		it("should have an interface when given one", function()
			local A = Interface("A")
			local B = Interface("B", A)
			expect(#B.__meta.__class.implementing).to.equal(1)
			expect(B.__meta.__class.implementing[1]).to.equal(A)
		end)

		it("should have multiple interfaces when given multiple", function()
			local A = Interface("A")
			local B = Interface("B")
			local C = Interface("C")
			local D = Interface("D", A, B, C)
			expect(#D.__meta.__class.implementing).to.equal(3)
			expect(D.__meta.__class.implementing[1]).to.equal(A)
			expect(D.__meta.__class.implementing[2]).to.equal(B)
			expect(D.__meta.__class.implementing[3]).to.equal(C)
		end)
	end)
end
