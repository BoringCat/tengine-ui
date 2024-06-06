#!/bin/sh

cp -rv /usr/local/etc/nginx/* /etc/nginx/
mkdir -p /var/cache/nginx/client_body_temp\
  /var/cache/nginx/proxy_temp\
  /var/cache/nginx/fastcgi_temp\
  /var/cache/nginx/uwsgi_temp\
  /var/cache/nginx/scgi_temp
