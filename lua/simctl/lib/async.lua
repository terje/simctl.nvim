local M = {}

-- https://github.com/iamcco/async-await.lua

local co = coroutine
local unp = table.unpack ~= nil and table.unpack or unpack

local function next_step(thread, success, ...)
  local res = { co.resume(thread, ...) }
  assert(res[1], unp(res, 2))
  if co.status(thread) ~= "dead" then
    res[2](function(...)
      next_step(thread, success, ...)
    end)
  else
    success(unp(res, 2))
  end
end

M.async = function(func)
  assert(type(func) == "function", "async params must be function")
  local res = {
    is_done = false,
    data = nil,
    cb = nil,
  }
  next_step(co.create(func), function(...)
    res.is_done = true
    res.data = { ... }
    if res.cb ~= nil then
      res.cb(unp(res.data))
    end
  end)
  return function(cb)
    if cb ~= nil and res.is_done then
      cb(unp(res.data))
    else
      res.cb = cb
    end
  end
end

M.await = function(async_cb)
  assert(type(async_cb) == "function" or type(async_cb) == "table", "await params must be function or table")
  return co.yield(async_cb)
end

return M
