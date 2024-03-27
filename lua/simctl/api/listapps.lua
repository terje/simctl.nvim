local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")

local function filterAppsByType(parentTbl, appType)
	local filteredApps = {}
	for key, subTbl in pairs(parentTbl) do
		if subTbl.ApplicationType == appType then
			filteredApps[key] = subTbl
		end
	end
	return filteredApps
end

M.AppType = {
	User = "User",
	System = "System",
}

M.listapps = function(args, callback)
	callback = callback or function() end

	args = util.merge(args or {}, {
		simulatorId = "booted",
	})

	simctl.execute({ "listapps", "booted" }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)

			callback(false, nil, stdout, stderr)
			return
		end

		vim.schedule(function()
			local tmpFilePath = os.tmpname()
			local file = io.open(tmpFilePath, "w")
			if file then
				file:write(stdout)
				file:close()
			else
				callback(false)
				return
			end

			local command = string.format('plutil -convert json -o - "%s"', tmpFilePath)
			local jsonOutput = vim.fn.system(command)

			-- Check for error
			if vim.v.shell_error ~= 0 then
				callback(false, nil, jsonOutput, nil)
				os.remove(tmpFilePath)
				return
			end

			local apps = vim.json.decode(jsonOutput)

			if args.appType then
				apps = filterAppsByType(apps, args.appType)
			end

			os.remove(tmpFilePath)

			callback(true, apps)
		end)
	end)
end

return M
