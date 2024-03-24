# simctl.nvim

## ⚠️ In early development ⚠️

This plugin is currently in the early stages of planning and development so it is not fit for general use yet.

## 📱 ➕ ⌨️ 🟰 🚀

NeoVim plugin to interact with iOS Simulators straight from the comfort of your editor. It provides a lua API for `simctl`, Apple's command line tool.

Have you ever found yourself context switching all the time when you are developing against the iOS Simulator? Tired of having to use the mouse to quit apps, going through the tedious two-three click process of deleting apps before trying a fresh install or having to do other manual steps every time you run your app in development? This plugin is for you!

## Planned features

* Lua API with coverage of any `simctl` functions that might be useful from NeoVim
* Telescope integration for selecting simulators and actions
* Support for .apns-files for sending push notifications to simulators

## Example uses

* Build your own custom actions in NeoVim to interact with or retrieve information from a running simulator, such as resetting, installing or uninstalling apps or resetting device state as part of your dev pipeline.
* Boot or shut down simulators.
* Test push notifications from NeoVim
