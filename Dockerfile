FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y curl gpg lsb-release socat

# https://pkg.cloudflareclient.com/
RUN curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | \
    gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/cloudflare-client.list && \
    apt-get update && \
    apt-get install -y cloudflare-warp

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    rm /usr/bin/warp-diag /usr/bin/warp-dex /usr/bin/warp-taskbar

COPY --chmod=755 entrypoint.sh healthcheck.sh /usr/local/bin/

ENV PROXY_PORT=1080 \
    WARP_PORT=40000 \
    VERBOSE=0 \
    RESTART=0

EXPOSE 1080/tcp

ENTRYPOINT ["entrypoint.sh"]
