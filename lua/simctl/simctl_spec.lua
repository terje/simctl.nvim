assert = require("luassert")

local simctl = require("simctl")
local config = require("simctl.config")

describe("simctl", function()
  it("should default notify to enabled", function()
    simctl.setup()
    assert.is_true(config.options.notify)
  end)

  it("should set notify to disabled", function()
    simctl.setup({ notify = false })
    assert.is_false(config.options.notify)
  end)
end)
