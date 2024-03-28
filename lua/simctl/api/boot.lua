local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")

M.boot = function(args, callback)
	callback = callback or function() end

	if args.deviceId == nil then
		util.notify("No deviceId provided", vim.log.levels.ERROR)
		callback(false)
		return
	end

	args = util.merge(args, {})

	simctl.execute({ "boot", args.deviceId }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, nil, stdout, stderr)
	end)
end

return M
