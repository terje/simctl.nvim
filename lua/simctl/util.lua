local M = {}

M.execute = function(command, callback)
	callback = callback or function() end
	vim.fn.jobstart(command, { on_exit = callback })
end

return M
