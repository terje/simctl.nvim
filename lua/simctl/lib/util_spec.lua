assert = require("luassert")

local stub = require("luassert.stub")
local util = require("simctl.lib.util")

describe("util", function()
  local config

  before_each(function()
    config = require("simctl.config")
    config.options.notify = true
  end)

  it("should merge two tables", function()
    local defaults = { a = 1, b = 2 }
    local args = { b = 3, c = 4 }
    local result = util.merge(args, defaults)

    assert.are.same({ a = 1, b = 3, c = 4 }, result)
  end)

  it("should merge two tables with defaults", function()
    local defaults = { a = 1, b = 2 }
    local args = { b = 3, c = 4 }
    local result = util.merge(args)

    assert.are.same({ b = 3, c = 4 }, result)
  end)

  it("should merge two tables with args", function()
    local args = { b = 3, c = 4 }
    local result = util.merge(args)

    assert.are.same({ b = 3, c = 4 }, result)
  end)

  it("should merge two tables with no args", function()
    local result = util.merge()

    assert.are.same({}, result)
  end)

  it("should notify with message", function()
    local message = "Hello, World!"
    local level = vim.log.levels.INFO
    stub(vim, "notify")
    util.notify(message, level)

    assert.stub(vim.notify).was.called_with("iOS Simulator: " .. message, level)
  end)

  it("should not notify if config disables it", function()
    config.options.notify = false
    local message = "Hello, World!"
    local level = vim.log.levels.INFO
    stub(vim, "notify")
    util.notify(message, level)

    assert.stub(vim.notify).was_not_called()
  end)

  it("should notify with message and level", function()
    local message = "Hello, World!"
    local level = vim.log.levels.ERROR
    stub(vim, "notify")
    util.notify(message, level)

    assert.stub(vim.notify).was.called_with("iOS Simulator: " .. message, level)
  end)

  it("should notify with message and default level", function()
    local message = "Hello, World!"
    stub(vim, "notify")
    util.notify(message)

    assert.stub(vim.notify).was.called_with("iOS Simulator: " .. message, vim.log.levels.INFO)
  end)

  it("should trim string", function()
    local s = "  Hello, World!  "
    local result = util.trim(s)

    assert.are.same("Hello, World!", result)
  end)

  it("should trim empty string", function()
    local s = "  "
    local result = util.trim(s)

    assert.are.same("", result)
  end)

  it("should provide a default callback and notify of success", function()
    local message = "Hello, World!"
    stub(vim, "notify")
    util.defaultCallback(true, message)

    assert.stub(vim.notify).was.called_with("iOS Simulator: " .. message, vim.log.levels.INFO)
  end)

  it("should provide a default callback and notify of error", function()
    local message = "Hello, World!"
    stub(vim, "notify")
    util.defaultCallback(false, message)

    assert.stub(vim.notify).was.called_with("iOS Simulator: " .. message, vim.log.levels.ERROR)
  end)
end)
