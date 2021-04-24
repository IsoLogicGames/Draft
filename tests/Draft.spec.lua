--- Tests for the @{Draft} API.

return function()
	local module = game:GetService("ReplicatedStorage").Draft
	local Draft = require(module)
	local Class = require(module.Class)
	local Interface = require(module.Interface)
	local Object = require(module.Object)

	describe("API", function()
		it("should be able to be instantiated", function()
			local draft = Draft.new()
			expect(draft).to.be.ok()
		end)

		it("should be a singleton", function()
			local draft = Draft.new()
			expect(draft).to.equal(Draft)
		end)

		it("should expose the Class function", function()
			expect(Draft.Class).to.equal(Class)
		end)

		it("should expose the Interface function", function()
			expect(Draft.Interface).to.equal(Interface)
		end)

		it("should expose the Object class", function()
			expect(Draft.Object).to.equal(Object)
		end)
	end)
end
