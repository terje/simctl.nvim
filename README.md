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

## Features - a bird's eye view

The provided Lua API provides coverage of any `simctl` functions that might be most useful from NeoVim, such as launching and terminating apps, booting and shutting down devices, erasing devices and setting UI options.

There is also support for testing push notifications, either through the API function, or directly from an .apns or .json file using the `SimctlNotify` command.

## Push notifications

The `SimctlNotify` command is automatically registered for `.json` and `.apns` files. The same action is registered for both, although the convention is for plain json files to only include the notification payload and the `.apns` file to include an additional `"Simulator Target Bundle"` indicating the app bundle ID to target:

```json
{
    "Simulator Target Bundle": "com.test.MyNotifiedApp",
    "aps": {
        "alert": {
            "title": "NeoVim says hello",
            "body": "Your favourite editor sends its greetings"
        }
    }
}
```

Run the command `:SimctlNotify` or assign this to your keymap for quick access to send this notification to a booted device. The command takes two optional arguments, a deviceId and an app bundle ID.

## Available API functions

### Boot (start) device

```lua
local args = {
    deviceId = "FE4BD15E-C65C-45DB-960A-78A771B16D17" -- Device ID. Required
}

local callback = function(success, _, stdout, stderr)
end

require("simctl.api").boot(args, callback)
```

### Erase (reset) device

```lua
local args = {
    deviceId = "FE4BD15E-C65C-45DB-960A-78A771B16D17" -- Device ID. Required. Can be "all" for all devices.
}

local callback = function(success, _, stdout, stderr)
end

require("simctl.api").erase(args, callback)
```

### Launch app

```lua
local args = {
    appId = "host.exp.Exponent", -- The app to launch. Required
    deviceId = "FE4BD15E-C65C-45DB-960A-78A771B16D17" -- Device ID. Optional, will pick a running simulator if not supplied ("booted").
}

local callback = function(success, _, stdout, stderr)
end

require("simctl.api").launch(args, callback)
```

### List available devices

```lua
local callback = function(success, devices, stdout, stderr)
end

require("simctl.api").list(callback)
```

### List installed apps

```lua
local simctl = require("simctl.api")

local args = {
    deviceId = "FE4BD15E-C65C-45DB-960A-78A771B16D17" -- Device ID. Optional, will pick a running simulator if not supplied ("booted").
    appType = simctl.AppType.User -- Optional. Returns all apps if not filtered
}

local callback = function(success, apps, stdout, stderr)
end

simctl.listapps(args, callback)
```

### Open URL

```lua

local args = {
    deviceId = "FE4BD15E-C65C-45DB-960A-78A771B16D17" -- Device ID. Optional, will pick a running simulator if not supplied ("booted").
    url = "https://soundthesea.com" -- The URL to open. Required
}

local callback = function(success, _, stdout, stderr)
end

require("simctl.api").openurl(args, callback)
```

### Send a push notification

```lua
local args = {
    appId = "com.test.MyNotifiedApp" -- App bundle ID. Required.
    deviceId = "FE4BD15E-C65C-45DB-960A-78A771B16D17" -- Device ID. Optional, will pick a running simulator if not supplied ("booted").
    payload = "[JSON]" -- The json payload of the push message (see format above in the SimctlNotify documentation)
}

require("simctl.api").push(args)
```



### Shut down device

```lua
local args = {
    deviceId = "FE4BD15E-C65C-45DB-960A-78A771B16D17" -- Device ID. Required. Can also be "all" to shut down all running devices.
}

local callback = function(success, _, stdout, stderr)
end

require("simctl.api").shutdown(args, callback)
```

Simulators cannot be erased in their Booted state so they have to be shut down first:

```lua
local simctl = require("simctl.api")
local device = { deviceId = "FE4BD15E-C65C-45DB-960A-78A771B16D17" }
simctl.shutdown(device, function(success)
  if success then
    simctl.erase(device, function(success)
        -- Next step of your dev workflow?
    end)
  end
end)
```

### Terminate app

```lua
local args = {
    appId = "host.exp.Exponent", -- The app to terminate. Required
    deviceId = "FE4BD15E-C65C-45DB-960A-78A771B16D17" -- Device ID. Optional, will pick a running simulator if not supplied ("booted").
}

local callback = function(success, _, stdout, stderr)
end

require("simctl.api").terminate(args, callback)
```

### Set UI options

```lua
local simctl = require("simctl.api")

-- Return current content size
simctl.ui.contentSize({}, function(success, contentSize)
    print(contentSize)
end)

-- Set content size to accessibility-large
simctl.ui.contentSize({ size = simctl.ui.ContentSize.ACCESSIBILITY_LARGE })

-- Increment content size
simctl.ui.contentSize({ size = simctl.ui.ContentSizeModifier.INCREMENT })

-- Return current appearance
simctl.ui.appearance({}, function(success, appearance)
    print(appearance)
end)

-- Set appearance to dark
simctl.ui.appearance({ appearance = simctl.ui.Appearance.DARK })

```

### Uninstall app

```lua
local args = {
    appId = "host.exp.Exponent", -- The app to terminate. Required
    deviceId = "FE4BD15E-C65C-45DB-960A-78A771B16D17" -- Device ID. Optional, will pick a running simulator if not supplied ("booted").
}

local callback = function(success, _, stdout, stderr)
end

require("simctl.api").uninstall(args, callback)
```

### Future

* Build your own custom actions in NeoVim to interact with or retrieve information from a running simulator, such as resetting, installing or uninstalling apps or resetting device state as part of your dev workflow.
* Boot or shut down simulators.
* Test push notifications from NeoVim
* Telescope integration for selecting simulators and actions
