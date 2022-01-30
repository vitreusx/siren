from jinja2 import Template
import os

nginx_conf_j2 = open("nginx.conf.j2", "r").read()

compiled = Template(nginx_conf_j2).render({
    "SERVER_PORT": os.getenv("SERVER_PORT"),
    "WEB_PORT": os.getenv("WEB_PORT")
})

open("nginx.conf", "w").write(compiled)