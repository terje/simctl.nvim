local api = require("simctl.api")
local aw = require("simctl.lib.async")

aw.async(function()
  vim.print("Test: Boot device")
  aw.await(function(cb)
    api.boot({}, cb)
  end)
  vim.print("Should have booted device")

  vim.print("Test: Launch app")
  aw.await(function(cb)
    api.launch({}, cb)
  end)
  vim.print("Should have launched app")

  vim.print("Test: Launch app on booted device")
  aw.await(function(cb)
    api.launch({ deviceId = "booted" }, cb)
  end)
  vim.print("Should have launched app")

  vim.print("Test: Shut down device")
  aw.await(function(cb)
    api.shutdown({}, cb)
  end)
  vim.print("Should have shut down device")
end)