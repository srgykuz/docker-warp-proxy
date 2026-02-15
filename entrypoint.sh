#!/bin/bash

daemon_is_running() {
    if warp-cli --accept-tos status 2>&1 | grep -q "daemon is not running"; then
        return 1
    else
        return 0
    fi
}

warp_is_connected() {
    if warp-cli --accept-tos status 2>&1 | grep -q "Connected"; then
        return 0
    else
        return 1
    fi
}

clear_logs() {
    while true; do
        sleep 5m
        find /var/lib/cloudflare-warp -type f -name "cfwarp*.txt*" -exec truncate -s 0 {} \;
    done
}

restart_warp() {
    sleep 1d
    kill 1
}

daemon_pid=""
socat_pid=""

stop() {
    echo
    echo "Terminating..."

    if [ -n "$daemon_pid" ]; then
        kill -SIGTERM "$daemon_pid"
    fi

    if [ -n "$socat_pid" ]; then
        kill -SIGTERM "$socat_pid"
    fi

    wait $daemon_pid $socat_pid
    echo "Terminated"
    exit 0
}

trap stop SIGINT SIGTERM

if [[ -z "$PROXY_PORT" || -z "$WARP_PORT" ]]; then
    echo "Invalid configuration"
    exit 1
fi

output="/dev/null"

if [[ -n "$VERBOSE" && "$VERBOSE" != "0" ]]; then
    output="/dev/stdout"
fi

echo "[1/3] Loading..."

warp-svc > "$output" 2>&1 &
daemon_pid=$!

for _ in {1..10}; do
    if daemon_is_running; then
        break
    fi

    sleep 1
done

if ! daemon_is_running; then
    echo "Error. Enable verbose output and debug"
    exit 1
fi

echo "[2/3] Loading..."

warp-cli --accept-tos registration new > "$output" 2>&1
warp-cli --accept-tos mode proxy > "$output" 2>&1
warp-cli --accept-tos proxy port $WARP_PORT > "$output" 2>&1
warp-cli --accept-tos connect > "$output" 2>&1

echo "[3/3] Loading..."

for _ in {1..30}; do
    if warp_is_connected; then
        break
    fi

    sleep 1
done

if ! warp_is_connected; then
    echo "Error. Enable verbose output and debug"
    exit 1
fi

socat \
    TCP-LISTEN:$PROXY_PORT,fork,reuseaddr \
    TCP:127.0.0.1:$WARP_PORT \
    > "$output" 2>&1 &
socat_pid=$!

echo "Ready at port $PROXY_PORT"

clear_logs &
logs_pid=$!

restart_pid=""

if [[ -n "$RESTART" && "$RESTART" != "0" ]]; then
    restart_warp &
    restart_pid=$!
fi

wait $daemon_pid $socat_pid $logs_pid $restart_pid
