local M = {}

local config = require("simctl.config")

M.execute = function(command, callback)
  callback = callback or function() end
  vim.fn.jobstart(command, { on_exit = callback })
end

M.notify = function(message, level)
  if config.options.notify then
    level = level or vim.log.levels.INFO
    vim.notify(message, level)
  end
end

M.errorCode = function(message)
  local pattern = "code=(%d+)"
  return tonumber(message:match(pattern))
end

return M
