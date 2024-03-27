# simctl.nvim

## ⚠️ In early development ⚠️

This plugin is currently in the early stages of planning and development so it is not fit for general use yet.

## 📱 ➕ ⌨️ 🟰 🚀

NeoVim plugin to interact with iOS Simulators straight from the comfort of your editor. It provides a lua API for `simctl`, Apple's command line tool.

Have you ever found yourself context switching all the time when you are developing against the iOS Simulator? Tired of having to use the mouse to quit apps, going through the tedious two-three click process of deleting apps before trying a fresh install or having to do other manual steps every time you run your app in development? This plugin is for you!

## Installation

Using Lazy:

```lua
{
  "terje/simctl.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
```

## Planned features

* Lua API with coverage of any `simctl` functions that might be useful from NeoVim
* Telescope integration for selecting simulators and actions
* Support for .apns-files for sending push notifications to simulators

## Example usage

### Close an app on all running iOS Simulators

```lua
require("simctl.api").terminate({ appId = "host.exp.Exponent" })
```

### Run an app on a specific iOS Simulator

```lua
require("simctl.api").execute({ appId = "host.exp.Exponent", simulatorId = "FE4BD15E-C65C-45DB-960A-78A771B16D17" }, function(success, stdout, stderr)
    if success then
        -- Next step of your dev workflow?
    end
end)
```

### Shut down and erase (reset) a specific iOS Simulator

Simulators cannot be erased in their Booted state so they have to be shut down first:

```lua
local simctl = require("simctl.api")
local simulator = "FE4BD15E-C65C-45DB-960A-78A771B16D17"
simctl.shutdown(simulator, function(success)
  if success then
    simctl.erase(simulator, function(success)
        -- Next step of your dev workflow?
    end)
  end
end)
```

### Future

* Build your own custom actions in NeoVim to interact with or retrieve information from a running simulator, such as resetting, installing or uninstalling apps or resetting device state as part of your dev workflow.
* Boot or shut down simulators.
* Test push notifications from NeoVim
