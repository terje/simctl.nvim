local M = {}

local config = require("simctl.config")

M.merge = function(args, defaults)
	for k, v in pairs(args) do
		defaults[k] = v
	end

	return defaults
end

M.notify = function(message, level)
	if not config.options.notify then
		return
	end

	level = level or vim.log.levels.INFO
	vim.notify("iOS Simulator: " .. message, level)
end

return M
