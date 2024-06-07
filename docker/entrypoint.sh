#!/bin/sh

set -o pipefail
set -e

mainPID=1

function _pid_exists(){
  local _pid=$1
  [ -d "/proc/${PID}/fd" ]
}

function _wait_pid() {
  local _pid=$1
  local _sleep=${2:-0.1}
  local _count=${3:-600}
  local _total=0
  while [ -d /proc/${PID}/fd -a ${_total} -lt ${_count} ]; do
    sleep ${_sleep}
    let _total+=1
  done
}

function _pre_stop() {
  if [ ! -f "/var/log/nginx/nginx.pid" ]; then
    return
  fi
  local nginxPID=`cat /var/log/nginx/nginx.pid 2>/dev/null || true`
  _pid_exists ${nginxPID} && nginx -s quit
  _wait_pid   ${nginxPID}
  _pid_exists ${mainPID}  && kill -2 ${mainPID}
  _wait_pid   ${mainPID}
}

trap _pre_stop SIGTERM SIGINT

[ ! -z "$TZ" -a -f "/usr/share/zoneinfo/${TZ}" ] && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime

nginx -t
nginx
/usr/local/bin/nginx-ui "$@" &

mainPID=$!
wait
_pre_stop
