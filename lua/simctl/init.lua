local M = {}

local config = require("simctl.config")

-- @param opts nil|table
M.setup = function(opts)
	config.setup(opts)
end

return M
