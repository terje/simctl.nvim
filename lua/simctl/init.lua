local M = {}

local config = require("simctl.config")
local autocmds = require("simctl.autocmds")

-- @param opts nil|table
M.setup = function(opts)
  config.setup(opts)
  autocmds.setup()
end

return M
