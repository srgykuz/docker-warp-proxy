curl -s -f --socks5 127.0.0.1:$PROXY_PORT https://www.cloudflare.com/cdn-cgi/trace/ | grep -q warp=on
