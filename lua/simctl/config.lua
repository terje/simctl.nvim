local M = {}

local defaults = {
	notify = true,
}

-- @param opts nil|table
M.setup = function(opts)
	M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

return M
