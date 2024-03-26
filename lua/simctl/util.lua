local M = {}

local config = require("simctl.config")

M.notify = function(message, level)
	if not config.options.notify then
		return
	end

	level = level or vim.log.levels.INFO
	vim.notify("iOS Simulator: " .. message, level)
end

return M
