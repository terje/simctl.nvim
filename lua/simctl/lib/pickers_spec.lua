---@diagnostic disable: duplicate-set-field
assert = require("luassert")

local stub = require("luassert.stub")
local mock = require("luassert.mock")
local match = require("luassert.match")
local pickers = require("simctl.lib.pickers")

describe("pickers", function()
  it("should pick from a table of values", function()
    local prompt = "Select a value"
    local values = { "a", "b", "c" }
    local callback = function(value)
      assert.are.equal("b", value)
    end
    stub(vim.ui, "select")
    pickers.pickTableValue(prompt, values, callback)

    assert.stub(vim.ui.select).was.called_with(values, { prompt = prompt }, match._)
  end)

  it("should call back with the selected value from the table", function()
    mock(vim.ui, true)
    vim.ui.select = function(values, options, callback)
      callback("b")
    end
    local values = { "a", "b", "c" }

    pickers.pickTableValue("test", values, function(value)
      assert.are.equal("b", value)
    end)
  end)

  it("should return empty result if no deviceId is provided", function()
    pickers.pickApp(nil, function(appId)
      assert.is_nil(appId)
    end)
  end)

  it("should return empty result if listapps fails", function()
    local simctl = require("simctl.api")
    mock(simctl, true)
    simctl.listapps = function(arg, callback)
      callback(false, nil)
    end

    pickers.pickApp("deviceId", function(appId)
      assert.is_nil(appId)
    end)
  end)
end)
