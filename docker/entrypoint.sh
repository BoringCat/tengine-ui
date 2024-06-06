#!/bin/sh

set -o pipefail
set -e

[ ! -z "$TZ" -a -f "/usr/share/zoneinfo/${TZ}" ] && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime

nginx -t
nginx
/usr/local/bin/nginx-ui "$@"