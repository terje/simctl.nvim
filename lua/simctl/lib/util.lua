local M = {}

local config = require("simctl.config")

M.merge = function(args, defaults)
	args = args or {}
	defaults = defaults or {}
	return vim.tbl_deep_extend("force", {}, defaults, args)
end

M.notify = function(message, level)
	if not config.options.notify then
		return
	end

	level = level or vim.log.levels.INFO
	vim.notify("iOS Simulator: " .. message, level)
end

M.trim = function(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

M.defaultCallback = function(success, result)
	if not success then
		M.notify(result, vim.log.levels.ERROR)
	end
end

return M
