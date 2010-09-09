from mongrel2.config import *

main = Server(
    uuid         = "2f62bd5-9e59-49cd-993c-3b6013c28f05",
    access_log   = "/log/access.log",
    error_log    = "/log/error.log",
    pid_file     = "/run/mongrel2.pid",
    chroot       = "./",
    default_host = "(.+)",
    name         = "main",
    port         = 8080
)

lua_handler = Handler(send_spec  = 'tcp://127.0.0.1:8989',
		send_ident = '34f9ceee-cd52-4b7f-b197-88bf2f0ec378',
		recv_spec  = 'tcp://127.0.0.1:8988',
		recv_ident = '')

server = Host(name="(.+)", routes={r'/': lua_handler})
main.hosts.add(server)
settings = {"zeromq.threads": 1}
commit([main], settings=settings)
