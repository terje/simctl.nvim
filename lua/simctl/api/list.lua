local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")

--- Launch app on a running or a specific iOS Simulator(s)
-- @param callback function The function to call upon completion. Optional
M.list = function(callback)
	callback = callback or function(_, _, _) end

	simctl.execute({ "list", "--json", "-e", "devices" }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)
		end

		local runtimes = vim.json.decode(stdout)
		local flattened = {}

		if not runtimes or not runtimes.devices then
			util.notify("No devices found")
			callback(false, nil, stdout, stderr)
			return
		end

		for runtime, devices in pairs(runtimes.devices) do
			local osVersion = runtime:match("iOS%-(%d+%-%d+)"):gsub("%-", ".")

			for _, device in ipairs(devices) do
				local flatDevice = {}

				for key, value in pairs(device) do
					flatDevice[key] = value
				end

				flatDevice.os = "iOS " .. osVersion

				table.insert(flattened, flatDevice)
			end
		end

		table.sort(flattened, function(a, b)
			return a.name < b.name
		end)

		callback(return_val == 0, flattened, stdout, stderr)
	end)
end

M.list()

return M
