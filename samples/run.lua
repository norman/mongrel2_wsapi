local mongrel2   = require 'mongrel2'
local m2w        = require 'mongrel2_wsapi'

local sender_id  = '318ced1c-85ec-462e-93ca-a1c721e4e072'
local sub_addr   = 'tcp://localhost:8989'
local pub_addr   = 'tcp://localhost:8988'
local io_threads = 1
local context    = mongrel2.new(io_threads)
local connection = context:new_connection(sender_id, sub_addr, pub_addr)

m2w.run(require('greetings'), context, connection)
