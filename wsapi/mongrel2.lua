-----------------------------------------------------------------------------
-- Mongrel2 WSAPI handler
--
-- Author: Norman Clarke
-- Copyright (c) 2010 Norman Clarke
--
-----------------------------------------------------------------------------
require "coxpcall"
require "lfs"

pcall = copcall
xpcall = coxpcall
local common = require "wsapi.common"

module (..., package.seeall)

-- These are duplicated here unless/until my recent patch to WSAPI is added.
local status_codes = {
  [100] = "Continue",
  [101] = "Switching Protocols",
  [200] = "OK",
  [201] = "Created",
  [202] = "Accepted",
  [203] = "Non-Authoritative Information",
  [204] = "No Content",
  [205] = "Reset Content",
  [206] = "Partial Content",
  [300] = "Multiple Choices",
  [301] = "Moved Permanently",
  [302] = "Found",
  [303] = "See Other",
  [304] = "Not Modified",
  [305] = "Use Proxy",
  [307] = "Temporary Redirect",
  [400] = "Bad Request",
  [401] = "Unauthorized",
  [402] = "Payment Required",
  [403] = "Forbidden",
  [404] = "Not Found",
  [405] = "Method Not Allowed",
  [406] = "Not Acceptable",
  [407] = "Proxy Authentication Required",
  [408] = "Request Time-out",
  [409] = "Conflict",
  [410] = "Gone",
  [411] = "Length Required",
  [412] = "Precondition Failed",
  [413] = "Request Entity Too Large",
  [414] = "Request-URI Too Large",
  [415] = "Unsupported Media Type",
  [416] = "Requested range not satisfiable",
  [417] = "Expectation Failed",
  [500] = "Internal Server Error",
  [501] = "Not Implemented",
  [502] = "Bad Gateway",
  [503] = "Service Unavailable",
  [504] = "Gateway Time-out",
  [505] = "HTTP Version not supported",
}

-- parse host name and port
local function parse_host(str)
  local host, port = str:match("(.+):(%d+)")
  if not host then host = str end
  if not port then port = 80 end
  port = tonumber(port)
  return host, port
end

-- Note: this is not in Mongrel2 1.0, but is slated to be included
-- soon. I'm not sure what format will ultimately be used, but
-- I'll assmume here it will be a comma-separated list of ip addresses
-- with the ip of the originating host listed first.
local function parse_remote_addr(str)
  if not str then return end
  return (str:match("(.-),"))
end

-- Ensure path is relative to the app prefix and begins with "/" if blank.
local function parse_path_info(path, app_prefix)
  local pattern = "^" .. (app_prefix or "") .. "(.*)"
  local path_info = string.match(path, pattern) or "/"
  path_info = path_info == "" and "/" or path_info
  return path_info
end

-- Set CGI vars from Mongrel2's headers.
local function get_cgi_vars(req, diskpath, app_prefix, extra_vars)
  diskpath = diskpath or req.diskpath or ""
  local vars = {}

  for k, v in pairs(req.headers) do
    vars["HTTP_" .. string.gsub(string.upper(k), "-", "_")] = v
  end

  -- Temporary, remove later
  vars.SERVER_SOFTWARE = "Mongrel2/1.0"

  vars.SERVER_NAME, vars.SERVER_PORT = parse_host(vars.HTTP_HOST)
  vars.CONTENT_LENGTH  = tonumber(vars.HTTP_CONTENT_LENGTH)
  vars.CONTENT_TYPE    = vars.HTTP_CONTENT_TYPE
  vars.PATH_INFO       = parse_path_info(vars.HTTP_PATH, app_prefix)
  vars.PATH_TRANSLATED = script_name_pat and (diskpath .. script_name_pat)
  vars.QUERY_STRING    = vars.HTTP_QUERY
  vars.REMOTE_ADDR     = parse_remote_addr(vars.HTTP_X_FORWARDED_FOR)
  vars.REQUEST_METHOD  = vars.HTTP_METHOD
  vars.REQUEST_URI     = vars.HTTP_URI
  vars.SCRIPT_NAME     = script_name_pat
  vars.SERVER_PROTOCOL = vars.HTTP_VERSION

  return vars
end

-- Sends the complete response through the "out" pipe,
-- using the provided write method
function common.send_output(out, status, headers, res_iter, write_method, res_line)
   local write = out[write_method or "write"]
   common.send_content(out, res_iter, write_method)
end


function run(app_run, context, connection, docroot)
  while true do
    local request = connection:recv()
    if request:is_disconnect() then
      io.stderr:write("Received disconnect")
    else
      local cgi_vars = get_cgi_vars(request)
      cgi_vars.DOCUMENT_ROOT = docroot or lfs.currentdir()
      local get_cgi_var = function(key)
        -- here for debugging the CGI vars, probably will remove this later
        if key == "CGI_VARS" then
          return cgi_vars
        else
          return cgi_vars[key] or ""
        end
      end

      local buffer = {}
      local output_buffer = {}
      function output_buffer:write(data)
        table.insert(buffer, data)
      end

      local input_buffer = {}
      function input_buffer:read()
        return request.body
      end

      local env = {
        input  = input_buffer,
        output = output_buffer,
        error  = io.stderr,
        env    = get_cgi_var
      }

      local code, headers = common.run(app_run, env)
      local status = tonumber(code) or tonumber(code:match("^(%d+)"))

      connection:reply_http(request,
        table.concat(buffer),
        status,
        status_codes[status],
        headers
      )
    end
  end
  context:term()
end

-- Used for testing some local functions.
function publish_funcs_for_testing()
  _M["parse_host"]       = parse_host
  _M["get_cgi_vars"]     = get_cgi_vars
  _M["parse_path_info"]  = parse_path_info
end
