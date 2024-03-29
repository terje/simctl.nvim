local M = {}

M.boot = require("simctl.api.boot").boot
M.erase = require("simctl.api.erase").erase
M.launch = require("simctl.api.launch").launch
M.list = require("simctl.api.list").list
M.listapps = require("simctl.api.listapps").listapps
M.openurl = require("simctl.api.openurl").openurl
M.push = require("simctl.api.push").push
M.shutdown = require("simctl.api.shutdown").shutdown
M.statusbar = require("simctl.api.statusbar").statusbar
M.terminate = require("simctl.api.terminate").terminate
M.ui = require("simctl.api.ui")
M.uninstall = require("simctl.api.uninstall").uninstall

M.AppType = require("simctl.api.listapps").AppType
M.DataNetworkType = require("simctl.api.statusbar").DataNetworkType
M.WifiMode = require("simctl.api.statusbar").WifiMode
M.CellularMode = require("simctl.api.statusbar").CellularMode
M.BatteryState = require("simctl.api.statusbar").BatteryState
M.StatusBarFlag = require("simctl.api.statusbar").StatusBarFlag

return M
