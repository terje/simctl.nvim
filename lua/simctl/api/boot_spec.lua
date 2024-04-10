local assert = require("luassert")
local match = require("luassert.match")
local mock = require("luassert.mock")
local stub = require("luassert.stub")
local config = require("simctl.config")
local erase = require("simctl.api.erase")

describe("api.boot", function()
  it("should open Simulator.app if the option is set", function()
    config.options.openSimulatorApp = true

    local simctl = require("simctl.lib.simctl")
    mock(simctl, true)
    simctl.execute = function(args, callback)
      callback(0, nil, nil, nil)
    end

    local util = require("simctl.lib.util")
    stub(util, "openSimulatorApp")

    local api = require("simctl.api")
    api.boot({ deviceId = "12345" })

    assert.stub(util.openSimulatorApp).was_called()
  end)

  it("should not open Simulator.app if the option is disabled", function()
    config.options.openSimulatorApp = false

    local simctl = require("simctl.lib.simctl")
    mock(simctl, true)
    simctl.execute = function(args, callback)
      callback(0, nil, nil, nil)
    end

    local util = require("simctl.lib.util")
    stub(util, "openSimulatorApp")

    local api = require("simctl.api")
    api.boot({ deviceId = "12345" })

    assert.stub(util.openSimulatorApp).was_not_called()
  end)
end)
