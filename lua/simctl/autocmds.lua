local M = {}

local simctl = require("simctl.api")
local util = require("simctl.lib.util")

local init = function()
  vim.api.nvim_buf_create_user_command(0, "SimctlNotify", function(opts)
    local args = opts.args
    local file_extension = vim.fn.expand("%:e")
    local deviceId, appId = args:match("(%S+)%s*(%S*)")

    if not deviceId or deviceId == "" then
      deviceId = "Booted"
    end

    local payload = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    local json = vim.fn.json_decode(payload)

    if not appId and json then
      appId = json["Simulator Target Bundle"]
    end

    if not appId then
      util.notify("SimctlNotify requires an appId or Simulator Target Bundle")
      return
    end

    local callback = function(success)
      if success then
        vim.notify("Notification sent")
        vim.schedule(function()
          vim.api.nvim_out_write("Notification sent")
        end)
      end
    end

    local filePath = vim.fn.expand("%:p")

    simctl.push({
      deviceId = deviceId,
      appId = appId,
      payload = filePath,
    }, callback)
  end, { desc = "Send .apns or .json content to a simulator using simctl", nargs = "*" })
end

M.setup = function()
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.apns", "*.json" },
    callback = init,
  })
end

return M
