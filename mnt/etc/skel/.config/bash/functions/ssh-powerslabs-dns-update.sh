#!/bin/bash

# Dynamic DNS updater for ssh.powerslabs.org
# Uses Mythic Beasts DNS API v2 dynamic endpoint <kcite ref="4"/>
# Intended to be run via cron every hour

SECRETS_MANAGER="$HOME/.config/bash/functions/secrets-manager.sh"
LOG_FILE="$HOME/.local/log/dns-updater.log"
DOMAIN="powerslabs.org"
HOSTNAME="ssh"

# ─── Logging ─────────────────────────────────────────────────────────────────

log() {
    local level="$1"
    local msg="$2"
    echo "[$(date '+%Y-%m-%d %I:%M:%S %p')] [$level] $msg" >> "$LOG_FILE"
}

# ─── Setup ───────────────────────────────────────────────────────────────────

mkdir -p "$(dirname "$LOG_FILE")"

# Source secrets manager
if [[ ! -f "$SECRETS_MANAGER" ]]; then
    log "ERROR" "Secrets manager not found at $SECRETS_MANAGER"
    exit 1
fi

source "$SECRETS_MANAGER"

# Load DNS credentials from encrypted secrets
secrets-set dns > /dev/null 2>&1

if [[ -z "$SSH_POWERSLABS_KEY" || -z "$SSH_POWERSLABS_SECRET" ]]; then
    log "ERROR" "DNS credentials not loaded. Run: secrets-add dns SSH_POWERSLABS_KEY <key> SSH_POWERSLABS_SECRET <secret>"
    exit 1
fi

# ─── IP Check ────────────────────────────────────────────────────────────────

CURRENT_IP=$(curl -s --max-time 10 https://api.ipify.org)

if [[ -z "$CURRENT_IP" ]]; then
    log "ERROR" "Could not determine current public IP"
    exit 1
fi

CURRENT_DNS_IP=$(dig +short "$HOSTNAME.$DOMAIN" @8.8.8.8 2>/dev/null | head -n1)

if [[ "$CURRENT_IP" == "$CURRENT_DNS_IP" ]]; then
    log "INFO" "IP unchanged ($CURRENT_IP), no update needed"
    exit 0
fi

log "INFO" "IP changed: '$CURRENT_DNS_IP' -> '$CURRENT_IP', updating DNS..."

# ─── DNS Update ──────────────────────────────────────────────────────────────

# Mythic Beasts dynamic DNS endpoint auto-detects the client IP and sets the A record <kcite ref="4"/>
RESPONSE=$(curl -s -w "\n%{http_code}" \
    --max-time 15 \
    --user "$SSH_POWERSLABS_KEY:$SSH_POWERSLABS_SECRET" \
    "https://api.mythic-beasts.com/dns/v2/zones/$DOMAIN/dynamic/$HOSTNAME")

HTTP_BODY=$(echo "$RESPONSE" | head -n1)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [[ "$HTTP_CODE" == "200" ]]; then
    log "SUCCESS" "Updated $HOSTNAME.$DOMAIN -> $CURRENT_IP"
else
    log "ERROR" "API call failed (HTTP $HTTP_CODE): $HTTP_BODY"
    exit 1
fi

# ─── Cleanup ─────────────────────────────────────────────────────────────────

unset SSH_POWERSLABS_KEY SSH_POWERSLABS_SECRET
