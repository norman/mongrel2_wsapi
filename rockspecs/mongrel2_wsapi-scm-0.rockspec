package = "mongrel2_wsapi"
version = "scm-0"
source = {
   url = "git://github.com/norman/mongrel2_wsapi.git",
}
description = {
   summary = "A WSAPI handler for Mongrel2.",
   license = "MIT/X11",
   homepage = "http://github.com/norman/mongrel2_wsapi"
}
dependencies = {
   "lua >= 5.1",
   "mongrel2-lua",
   "wsapi",
   "coxpcall"
}

build = {
  type = "none",
  install = {
    lua = {
      mongrel2_wsapi = "mongrel2_wsapi.lua"
    }
  }
}
