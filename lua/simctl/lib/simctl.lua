local M = {}

M.errors = {
	[3] = "App not found.",
	[405] = "Cannot run command while Simulator is in this state.",
}

local extractedErrorCode = function(message)
	local pattern = "code=(%d+)"
	return tonumber(message:match(pattern))
end

local humaneMessage = function(message)
	return M.errors[extractedErrorCode(message)]
end

M.execute = function(args, callback)
	local simctlArguments = { "simctl" }
	for _, v in ipairs(args) do
		table.insert(simctlArguments, v)
	end

	vim.system({
		"xcrun",
		unpack(simctlArguments),
	}, { text = true }, function(result)
		callback(result.code, humaneMessage(result.stderr), result.stdout, result.stderr)
	end)
end

return M
