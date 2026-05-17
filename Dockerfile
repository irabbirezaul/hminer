FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV CONVEX_URL=https://quixotic-minnow-62.eu-west-1.convex.site

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    jq \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /miner

RUN if grep -q avx2 /proc/cpuinfo; then \
        FILE=hellminer_linux64_avx2.tar.gz; \
    elif grep -q avx /proc/cpuinfo; then \
        FILE=hellminer_linux64_avx.tar.gz; \
    else \
        FILE=hellminer_linux64.tar.gz; \
    fi \
    && wget -q "https://github.com/hellcatz/hminer/releases/download/v0.59.1/$FILE" \
    && tar -xzf "$FILE" \
    && rm "$FILE" \
    && chmod +x hellminer

COPY start.sh /miner/start.sh
RUN chmod +x /miner/start.sh

CMD ["/miner/start.sh"]
