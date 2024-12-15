local M = {}

M.check = function()
	vim.health.start("simctl")
	local xcrun = vim.fn.executable("xcrun") ~= 0
	if xcrun then
		vim.health.ok("xcrun command found in $PATH")
	else
		vim.health.error("xcrun command not found in $PATH. Is Xcode installed?")
	end
end

return M
