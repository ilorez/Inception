FROM debian:bullseye

# Uptime Kuma needs Node.js >= 20.4 — bullseye's own apt repo only has Node 12,
# so we pull Node 20 from NodeSource. build-essential/python3 are needed to
# compile native modules (e.g. sqlite3) during npm install.
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    git \
    python3 \
    build-essential \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
       | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" \
       > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone a pinned release (2.4.0) instead of master, so a build today
# doesn't break the day of your defense
RUN git clone --depth 1 --branch 2.4.0 https://github.com/louislam/uptime-kuma.git . \
    && npm run setup

# EXPOSE 3001

CMD ["node", "server/server.js"]