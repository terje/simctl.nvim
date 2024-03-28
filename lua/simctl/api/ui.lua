local M = {}

local util = require("simctl.lib.util")
local simctl = require("simctl.lib.simctl")

M.ContentSizeModifier = {
	INCREMENT = "increment",
	DECREMENT = "decrement",
}

M.ContentSize = {
	EXTRA_SMALL = "extra-small",
	SMALL = "small",
	MEDIUM = "medium",
	LARGE = "large",
	EXTRA_LARGE = "extra-large",
	EXTRA_EXTRA_LARGE = "extra-extra-large",
	EXTRA_EXTRA_EXTRA_LARGE = "extra-extra",
	ACCESSIBILITY_MEDIUM = "accessibility-medium",
	ACCESSIBILITY_LARGE = "accessibility-large",
	ACCESSIBILITY_EXTRA_LARGE = "accessibility-extra-large",
	ACCESSIBILITY_EXTRA_EXTRA_LARGE = "accessibility-extra-extra-large",
	ACCESSIBILITY_EXTRA_EXTRA_EXTRA_LARGE = "accessibility-extra-extra-extra-large",
}

local function isValidContentSizeModifier(modifier)
	for _, v in pairs(M.ContentSizeModifier) do
		if v == modifier then
			return true
		end
	end
	return false
end

local function isValidContentSize(size)
	for _, v in pairs(M.ContentSize) do
		if v == size then
			return true
		end
	end
	return false
end

--- Get or set the content size of a running or a specific iOS Simulator(s)
-- @param args Table containing the following keys:
-- @param args.size string The new size of the content. Returns the current size if not supplied.
M.contentSize = function(args, callback)
	callback = callback or function(_, _, _) end

	args = util.merge(args, {
		deviceId = "booted",
	})

	if args.size and not isValidContentSize(args.size) and not isValidContentSizeModifier(args.size) then
		util.notify(args.size .. " is not a valid content size", vim.log.levels.ERROR)
		callback(false)
		return
	end

	simctl.execute({ "ui", args.deviceId, "content_size", args.size }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)

			callback(false, nil, stdout, stderr)
			return
		end

		callback(return_val == 0, stdout, stdout, stderr)
	end)
end

M.Appearance = {
	LIGHT = "light",
	DARK = "dark",
}

local isValidAppearance = function(appearance)
	for _, v in pairs(M.Appearance) do
		if v == appearance then
			return true
		end
	end
	return false
end

--- Get or set the appearance of all running or a specific iOS Simulator(s)
-- @param args Table containing the following keys:
-- @param args.size string The appearance. Returns the current appearance if not supplied.
M.appearance = function(args, callback)
	callback = callback or function(_, _, _) end

	args = util.merge(args, {
		deviceId = "booted",
	})

	if args.appearance and not isValidAppearance(args.appearance) then
		util.notify(args.appearance .. " is not a valid appearance", vim.log.levels.ERROR)
		callback(false)
		return
	end

	simctl.execute({ "ui", args.deviceId, "appearance", args.appearance }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)

			callback(false, nil, stdout, stderr)
			return
		end

		callback(return_val == 0, stdout, stdout, stderr)
	end)
end

M.increaseContrast = function(args, callback)
	callback = callback or function(_, _, _) end

	args = util.merge(args, {
		deviceId = "booted",
	})

	if args.enabled and not type(args.enabled) == "boolean" then
		util.notify(args.enabled .. " is not a boolean", vim.log.levels.ERROR)
		callback(false)
		return
	end

	local enabled
	if args.enabled ~= nil then
		enabled = args.enabled and "enabled" or "disabled"
	end

	simctl.execute({ "ui", args.deviceId, "increase_contrast", enabled }, function(return_val, humane, stdout, stderr)
		if return_val ~= 0 then
			local message = humane or stderr
			util.notify(message)

			callback(false, nil, stdout, stderr)
			return
		end

		local result
		if args.enabled == nil then
			result = string.find(stdout, "enabled", 1, true) ~= nil
		end

		callback(return_val == 0, result, stdout, stderr)
	end)
end

return M
