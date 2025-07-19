#!/bin/sh

# Configuration
REMOTE_HOST="connect.tonio.cc"
REMOTE_USER="ananchev"
REMOTE_SSH_PORT="80"
PRIVATE_KEY="/root/.ssh/id_dropbear_vhost"
REVERSE_SSH_PORT="2223"
REVERSE_WEB_PORT="8081"
LOCK_FILE="/var/run/reverse-ssh-tunnel.lock"
LOG_FILE="/var/log/reverse-ssh-tunnel.log"

# SSH options
SSH_OPTS="-i $PRIVATE_KEY -p $REMOTE_SSH_PORT -y"

# Logging function
log_msg() {
    echo "$(date): $1" >> $LOG_FILE
}

# Check if private key exists
if [ ! -f "$PRIVATE_KEY" ]; then
    log_msg "ERROR: Private key not found at $PRIVATE_KEY"
    exit 1
fi

# Check if already running
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        log_msg "Service already running (PID: $PID)"
        exit 0
    else
        rm -f "$LOCK_FILE"
    fi
fi

# Create lock file
echo $$ > "$LOCK_FILE"

# Cleanup on exit
trap 'rm -f "$LOCK_FILE"; exit 0' INT TERM EXIT

log_msg "Service started - tunneling SSH:$REVERSE_SSH_PORT, Web:$REVERSE_WEB_PORT"

# Start tunnel with retry logic
while true; do
    # Start the tunnel (this will hang if successful)
    ssh $SSH_OPTS -N \
        -R $REVERSE_SSH_PORT:localhost:22 \
        -R $REVERSE_WEB_PORT:localhost:80 \
        $REMOTE_USER@$REMOTE_HOST
    
    # Only log if tunnel drops
    log_msg "Tunnel disconnected - reconnecting in 30 seconds"
    sleep 30
done
