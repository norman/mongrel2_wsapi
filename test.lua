local m2 = require "mongrel2_wsapi"
m2.publish_funcs_for_testing()

local function make_request(vars)
  local request = {
    headers = {
      ["Accept"]          = "*/*",
      ["Accept-Charset"]  = "ISO-8859-1,utf-8;q=0.7,*;q=0.3",
      ["Accept-Encoding"] = "gzip,deflate,sdch",
      ["Accept-Language"] = "en-US,en;q=0.8",
      ["Cache-Control"]   = "max-age=0",
      ["Connection"]      = "keep-alive",
      ["Content-Length"]  = "7",
      ["Content-Type"]    = "application/x-www-form-urlencoded",
      ["Host"]            = "192.168.3.5:8080",
      ["METHOD"]          = "POST",
      ["PATH"]            = "/places",
      ["PATTERN"]         = "/",
      ["QUERY"]           = "hello=world",
      ["URI"]             = "/places?hello=world",
      ["User-Agent"]      = "curl/7.19.7",
      ["VERSION"]         = "HTTP/1.1",
      ["X-Forwarded-For"] = "1.2.3.4, 2.3.4.5"
    },
    body    = "foo=bar",
    conn_id = "7",
    path    = "/",
    sender  = "34f9ceee-cd52-4b7f-b197-88bf2f0ec378"
  }

  if vars then
    for k, v in pairs(vars) do
      request.headers[k] = v
    end
  end
  return request
end

-- Test hostname parsing
do
  local host, port = m2.parse_host("example.com:8080")
  print("should parse hostname")
  assert(host == "example.com")
  print("should parse port")
  assert(port == 8080)
end

do
  print("should parse port")
  local host, port = m2.parse_host("example.com")
  assert(port == 80)
end

-- Test setting CGI vars
do
  local vars = m2.get_cgi_vars(make_request())

  print("should get server name")
  assert(vars.SERVER_NAME == "192.168.3.5")

  print("should get protocol")
  assert(vars.SERVER_PROTOCOL == "HTTP/1.1")

  print("should get server port")
  assert(vars.SERVER_PORT == 8080)

  print("should get request method")
  assert(vars.REQUEST_METHOD == "POST")

  print("should get document root")
  assert(vars.DOCUMENT_ROOT == nil)

  print("should get path info")
  assert(vars.PATH_INFO == "/places")

  print("should get path_translated")
  assert(vars.PATH_TRANSLATED == nil)

  print("should get script name")
  assert(vars.SCRIPT_NAME == nil)

  print("should get query string")
  assert(vars.QUERY_STRING == "hello=world")

  print("should get remote address")
  assert(vars.REMOTE_ADDR == "1.2.3.4")

  print("should get request uri")
  assert(vars.REQUEST_URI == "/places?hello=world")

  print("should get content type")
  assert(vars.CONTENT_TYPE == "application/x-www-form-urlencoded")

  print("should get content length")
  assert(vars.CONTENT_LENGTH == 7)
end

do
  local vars = m2.get_cgi_vars(make_request())
  print("should reformat names of other vars in request.headers")
  assert(vars["HTTP_ACCEPT_CHARSET"] ~= nil)
end

do
  print("PATH_INFO should be set to '/' when blank")
  assert("/" == m2.parse_path_info "")
  assert("/" == m2.parse_path_info "/")
  assert("hello" == m2.parse_path_info "hello")
end

do
  print("PATH_INFO should exclude the app prefix")
  assert("hello" == m2.parse_path_info("/my_app/hello", "/my_app/"))
end
