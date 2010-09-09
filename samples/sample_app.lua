local mongrel2   = require 'mongrel2'
local m2w        = require 'mongrel2_wsapi'

local sender_id  = '318ced1c-85ec-462e-93ca-a1c721e4e072'
local sub_addr   = 'tcp://localhost:8989'
local pub_addr   = 'tcp://localhost:8988'
local io_threads = 1
local context    = mongrel2.new(io_threads)
local connection = context:new_connection(sender_id, sub_addr, pub_addr)

local function app_run(wsapi_env)
  local headers = {
    ["Content-type"]          = "text/html",
    ["X-Holy-Shit-It-Worked"] = "yup"
  }
  local buffer = {}
  table.insert(buffer, "<html><body>")
  table.insert(buffer, "<h1>WSAPI Env</h1>")
  table.insert(buffer, "<ul>")
  for k, v in pairs(wsapi_env.CGI_VARS) do
    table.insert(buffer, string.format("<li><strong>%s</strong>: %s</li>", k, tostring(v)))
  end
  table.insert(buffer, "</ul>")
  table.insert(buffer, "</body></html>")

  local function hello_text()
    coroutine.yield(table.concat(buffer, "\n"))
  end
  return 200, headers, coroutine.wrap(hello_text)
end

m2w.run(app_run, context, connection)
