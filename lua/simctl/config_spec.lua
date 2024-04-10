assert = require("luassert")

local simctl = require("simctl")
local config = require("simctl.config")

describe("config", function()
  it("should have a config even if setup hasn't been called", function()
    assert.is_table(config)
  end)

  it("should default notify to enabled", function()
    simctl.setup()
    assert.is_true(config.options.notify)
  end)

  it("should set notify to disabled", function()
    simctl.setup({ notify = false })
    assert.is_false(config.options.notify)
  end)

  it("should default devicePicker to enabled", function()
    simctl.setup()
    assert.is_true(config.options.devicePicker)
  end)

  it("should set devicePicker to disabled", function()
    simctl.setup({ devicePicker = false })
    assert.is_false(config.options.devicePicker)
  end)

  it("should default appPicker to enabled", function()
    simctl.setup()
    assert.is_true(config.options.appPicker)
  end)

  it("should set appPicker to disabled", function()
    simctl.setup({ appPicker = false })
    assert.is_false(config.options.appPicker)
  end)

  it("should set defaultToBootedDevice to disabled", function()
    simctl.setup()
    assert.is_false(config.options.defaultToBootedDevice)
  end)

  it("should set defaultToBootedDevice to enabled", function()
    simctl.setup({ defaultToBootedDevice = true })
    assert.is_true(config.options.defaultToBootedDevice)
  end)

  it("should set openSimulatorApp to enabled", function()
    simctl.setup()
    assert.is_true(config.options.openSimulatorApp)
  end)

  it("should set openSimulatorApp to disabled", function()
    simctl.setup({ openSimulatorApp = false })
    assert.is_false(config.options.openSimulatorApp)
  end)
end)
