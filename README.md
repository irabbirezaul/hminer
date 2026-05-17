# VRSC Hellminer

CPU miner for Verus Coin (VRSC) running in Docker. Auto-selects AVX2/AVX binary based on host CPU.

## Setup

Clone and configure your wallet in the Dockerfile:
```
ENV WALLET=your_wallet_address
ENV WORKER=worker1
ENV POOL=stratum+tcp://de.vipor.net:5040
ENV THREADS=4
```

## Run

```bash
docker build -t vrsc-miner .
docker run -d --restart unless-stopped vrsc-miner
```

Override settings without rebuilding:
```bash
docker run -d --restart unless-stopped \
  -e THREADS=8 \
  -e WORKER=rig2 \
  vrsc-miner
```

## Logs

```bash
docker logs -f <container_id>
```
