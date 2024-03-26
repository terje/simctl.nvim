local M = {}

local Job = require("plenary.job")

M.errors = {
	[3] = "App not found.",
	[405] = "Cannot run command while Simulator is in Booted state.",
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

	local stdoutBuffer = {}
	local stderrBuffer = {}

	Job:new({
		command = "xrun",
		args = simctlArguments,
		on_exit = function(_, return_val)
			local stderr = table.concat(stderrBuffer, "\n")
			local stdout = table.concat(stdoutBuffer, "\n")

			callback(return_val, humaneMessage(stderr), stdout, stderr)
		end,
		on_stdout = function(_, data)
			if data ~= "" then
				table.insert(stdoutBuffer, data)
			end
		end,
		on_stderr = function(_, data)
			if data ~= "" then
				table.insert(stderrBuffer, data)
			end
		end,
	}):start()
end

return M
