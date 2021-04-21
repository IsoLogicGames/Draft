--- Tests for the @{Draft} API.

return function()
	local module = game:GetService("ReplicatedStorage").Draft
	local Draft = require(module)

	describe("Draft", function()
		it("should be able to be instantiated", function()
			local draft = Draft.new()
			expect(draft).to.be.ok()
		end)

		it("should be a singleton", function()
			local draft = Draft.new()
			expect(draft).to.equal(Draft)
		end)
	end)
end
