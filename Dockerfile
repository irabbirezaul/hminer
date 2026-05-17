FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV WALLET=RTXJJtDXZxu9f6ritudxTMjf4u2Sdxq56g
ENV WORKER=worker1
ENV POOL=stratum+tcp://de.vipor.net:5040
ENV THREADS=48

RUN apt-get update && apt-get install -y \
    wget \
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

CMD ./hellminer -c "$POOL" -u "$WALLET.$WORKER" -p x --cpu "$THREADS"
