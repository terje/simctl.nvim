local assert = require("luassert")
local match = require("luassert.match")
local mock = require("luassert.mock")
local stub = require("luassert.stub")
local config = require("simctl.config")
local erase = require("simctl.api.erase")

describe("api.erase", function()
  config.options.notify = false

  it("should erase a device", function()
    local simctl = require("simctl.lib.simctl")
    mock(simctl, true)

    erase.erase({ deviceId = "booted" })

    assert.stub(simctl.execute).was.called_with({ "erase", "booted" }, match._)
  end)

  it("should present a device picker if the option is set and no deviceId is supplied", function()
    local pickers = require("simctl.lib.pickers")
    stub(pickers, "pickDevice")

    local simctl = require("simctl.lib.simctl")
    mock(simctl, true)
    simctl.execute = function(args, callback)
      callback(0, nil, nil, nil)
    end

    config.options.devicePicker = true
    erase.erase()

    assert.stub(pickers.pickDevice).was.called()
  end)

  it("should not present a device picker if the option is disabled", function()
    local pickers = require("simctl.lib.pickers")
    stub(pickers, "pickDevice")

    local simctl = require("simctl.lib.simctl")
    mock(simctl, true)
    simctl.execute = function(args, callback)
      callback(0, nil, nil, nil)
    end

    config.options.devicePicker = false
    erase.erase()

    assert.stub(pickers.pickDevice).was_not_called()
  end)

  it("should default to booted if the option is enabled", function()
    local pickers = require("simctl.lib.pickers")
    stub(pickers, "pickDevice")

    local simctl = require("simctl.lib.simctl")
    stub(simctl, "execute")

    config.options.devicePicker = false
    config.options.defaultToBootedDevice = true
    erase.erase()

    assert.stub(pickers.pickDevice).was_not_called()

    assert.stub(simctl.execute).was.called_with({ "erase", "booted" }, match._)
  end)

  it("should not default to booted if the option is disabled", function()
    local pickers = require("simctl.lib.pickers")
    stub(pickers, "pickDevice")

    local simctl = require("simctl.lib.simctl")
    stub(simctl, "execute")

    config.options.devicePicker = false
    config.options.defaultToBootedDevice = false
    erase.erase()

    assert.stub(simctl.execute).was_not_called()
  end)

  it("should not default to booted if a device is picked", function()
    local pickers = require("simctl.lib.pickers")
    mock(pickers, "pickDevice")
    pickers.pickDevice = function(callback)
      callback("12345")
    end

    local simctl = require("simctl.lib.simctl")
    stub(simctl, "execute")

    config.options.devicePicker = true
    config.options.defaultToBootedDevice = true
    erase.erase()

    assert.stub(simctl.execute).was.called_with({ "erase", "12345" }, match._)
  end)
end)
