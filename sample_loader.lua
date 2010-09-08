local mongrel2   = require 'mongrel2'
local common     = require 'wsapi.common'

local sender_id  = '318ced1c-85ec-462e-93ca-a1c721e4e072'
local sub_addr   = 'tcp://localhost:8989'
local pub_addr   = 'tcp://localhost:8988'
local io_threads = 1
local context    = mongrel2.new(io_threads)
local connection = context:new_connection(sender_id, sub_addr, pub_addr)

local wsapi_loader = common.make_loader{
  isolated = true,         -- isolate each script in its own Lua state
  reload = false,          -- if you want to reload the application on every request
  period = ONE_HOUR,       -- frequency of Lua state staleness checks
  ttl = ONE_DAY,           -- time-to-live for Lua states
}

local m2w = require 'wsapi.mongrel2'

m2w.run(wsapi_loader, context, connection)
