# docker-warp-proxy

Run Cloudflare Warp in proxy mode as a Docker container.

## Usage

1. Start Docker container
2. Wait for proxy loading
3. Use proxy at port 1080

The proxy supports SOCKS5 and HTTP.

### Docker

Run:

```bash
docker run -d -p 1080:1080 ghcr.io/srgykuz/warp-proxy:latest
```

Verify:

```bash
curl -x socks5h://127.0.0.1:1080 https://www.cloudflare.com/cdn-cgi/trace/
```

In output look for `warp=on`.

### Docker Compose

See [docker-compose.yml](docker-compose.yml).
