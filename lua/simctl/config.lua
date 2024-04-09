local M = {}

M.options = {
  notify = true,
  devicePicker = true,
  appPicker = true,
  defaultToBootedDevice = false,
}

-- @param opts nil|table
M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.options, opts or {})
end

return M
