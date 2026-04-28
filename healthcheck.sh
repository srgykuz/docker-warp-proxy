#!/bin/sh

curl -s -f --socks5 127.0.0.1:$PROXY_PORT https://www.cloudflare.com/cdn-cgi/trace | grep -q warp=on
code=$?

if [ "$code" -ne 0 ] && [ -n "$RESTART" ] && [ "$RESTART" != "0" ]; then
    kill 1
fi

exit $code
