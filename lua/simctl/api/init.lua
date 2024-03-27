local M = {}

M.erase = require("simctl.api.erase").erase
M.launch = require("simctl.api.launch").launch
M.listapps = require("simctl.api.listapps").listapps
M.openurl = require("simctl.api.openurl").openurl
M.push = require("simctl.api.push").push
M.shutdown = require("simctl.api.shutdown").shutdown
M.terminate = require("simctl.api.terminate").terminate
M.uninstall = require("simctl.api.uninstall").uninstall

M.AppType = require("simctl.api.listapps").AppType

return M
