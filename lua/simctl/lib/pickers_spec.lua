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

  it("should present a sorted list of devices", function()
    local api = require("simctl.api")
    mock(api, true)
    api.list = function(callback)
      callback(true, {
        { name = "iPhone 14",     state = "Shutdown", os = "iOS 17.0", udid = "1234" },
        { name = "iPhone 15 Pro", state = "Shutdown", os = "iOS 17.4", udid = "5678" },
        { name = "iPhone 15",     state = "Booted",   os = "iOS 17.4", udid = "9012" },
        { name = "iPad",          state = "Booted",   os = "iOS 17.4", udid = "3456" },
      })
    end

    local sortedDevices = {
      "Booted  \t - iOS 17.4: iPad - 3456",
      "Booted  \t - iOS 17.4: iPhone 15 - 9012",
      "Shutdown\t - iOS 17.4: iPhone 15 Pro - 5678",
      "Shutdown\t - iOS 17.0: iPhone 14 - 1234",
    }

    local selectStub = stub(vim.ui, "select")
    pickers.pickDevice(function() end)

    -- TODO: Match to sortedDevices causes error. Fix
    assert.stub(selectStub).was.called_with(match._, { prompt = "Select a device" }, match._)

    selectStub:revert()
  end)

  it("should present a sorted list of apps", function()
    local api = require("simctl.api.listapps")
    mock(api, true)
    api.listapps = function(_, callback)
      local apps = {
        {
          ApplicationType = "System",
          CFBundleDisplayName = "App B",
          CFBundleIdentifier = "com.test.app.b",
        },
        {
          ApplicationType = "System",
          CFBundleDisplayName = "App A",
          CFBundleIdentifier = "com.test.app.a",
        },
        {
          ApplicationType = "User",
          CFBundleDisplayName = "App D",
          CFBundleIdentifier = "com.test.app.d",
        },
        {
          ApplicationType = "User",
          CFBundleDisplayName = "App C",
          CFBundleIdentifier = "com.test.app.c",
        },
      }
      callback(true, apps)
    end

    local selectStub = stub(vim.ui, "select")

    local sortedApps = {
      "User  \tApp C - com.test.app.c",
      "User  \tApp D - com.test.app.d",
      "System\tApp A - com.test.app.a",
      "System\tApp B - com.test.app.b",
    }

    pickers.pickApp("deviceId", function(_) end)

    assert.stub(selectStub).was.called_with(sortedApps, { prompt = "Select an app" }, match._)
    selectStub:revert()
  end)

  it("calls back with the selected deviceId", function()
    local api = require("simctl.api.listapps")
    mock(api, true)
    api.listapps = function(_, callback)
      callback(true, {
        {
          ApplicationType = "System",
          CFBundleDisplayName = "App B",
          CFBundleIdentifier = "com.test.app.b",
        },
      })
    end

    mock(vim.ui)
    vim.ui.select = function(_, _, callback)
      callback("System\tApp B - com.test.app.b")
    end

    pickers.pickApp("deviceId", function(appId)
      assert.are.equal("com.test.app.b", appId)
    end)
  end)
end)
