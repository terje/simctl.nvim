local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")

M.openurl = function(args, callback)
	callback = callback or function() end

	if args.url == nil then
		util.notify("No url provided", vim.log.levels.ERROR)
		callback(false)
		return
	end

	args = util.merge(args, {
		simulatorId = "booted",
	})

	simctl.execute({ "openurl", args.simulatorId, args.url }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		callback(return_val == 0, nil, stdout, stderr)
	end)
end

return M
