FROM debian:latest

# Install dependencies and jotta-cli
RUN apt-get update && \
    apt-get install -y curl apt-transport-https ca-certificates expect && \
    curl -fsSL https://repo.jotta.cloud/jotta.gpg -o /usr/share/keyrings/jotta.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/jotta.gpg] https://repo.jotta.cloud/debian debian main" > /etc/apt/sources.list.d/jotta-cli.list && \
    apt-get update && \
    apt-get install -y jotta-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Disable systemd integration for jottad
ENV JOTTAD_SYSTEMD=0
ENV JOTTA_TOKEN=
ENV JOTTA_DEVICE_NAME="jotta-syncer"
ENV JOTTA_DATA_DIR=/root/.jottad

# Expose the jottad port (default 30000)
EXPOSE 30000

COPY jotta_login.exp /usr/local/bin/jotta_login.exp
RUN chmod +x /usr/local/bin/jotta_login.exp

COPY <<'EOF' /usr/local/bin/entrypoint.sh
#!/bin/bash

if [ -n "$(ls -A "$JOTTA_DATA_DIR")" ]; then
  echo "$JOTTA_DATA_DIR is not empty. Starting jottad with previous session..."
fi

if [ -z "$(ls -A "$JOTTA_DATA_DIR")" ] && [ -n "$JOTTA_TOKEN" ] && [ -n "$JOTTA_DEVICE_NAME" ]; then
  jottad&
  PID=$!
  sleep 1
  /usr/local/bin/jotta_login.exp
  SUCC=$?
  jotta-cli add /data
  kill $PID
  sleep 1
  [ $SUCC -eq 0 ] || { rm -rfv "$JOTTA_DATA_DIR";echo "jotta cloud login failed"; exit 1; }
fi

if [ -z "$(ls -A "$JOTTA_DATA_DIR")" ]; then
  echo "$JOTTA_DATA_DIR is empty and jotta-cli login failed. Did you provide JOTTA_TOKEN and JOTTA_DEVICE_NAME?"
  exit 1
fi

exec jottad "$@"
EOF
RUN chmod +x /usr/local/bin/entrypoint.sh

# Start the daemon
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
