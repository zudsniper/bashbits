#!/bin/bash
# test_smtp.sh v1.0.0

# Logging function
log() {
    local LEVEL=$1
    local MESSAGE=$2
    case "$LEVEL" in
        INFO) echo -e "\033[0;32m[INFO]\033[0m $MESSAGE" ;;
        WARN) echo -e "\033[0;33m[WARN]\033[0m $MESSAGE" ;;
        ERROR) echo -e "\033[0;31m[ERROR]\033[0m $MESSAGE" ;;
        *) echo -e "\033[0;34m[LOG]\033[0m $MESSAGE" ;;
    esac
}

# Ensure proper usage
if [ "$#" -lt 1 ] || [ "$#" -gt 4 ]; then
    log ERROR "Usage: $0 <smtp-server> [port] [username] [password]"
    exit 1
fi

SMTP_SERVER=$1
SMTP_PORT=${2:-25} # Default to port 25 (unencrypted SMTP) if not provided
USERNAME=$3
PASSWORD=$4

# Check if authentication is required
AUTH_REQUIRED=false
if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
    AUTH_REQUIRED=true
    ENCODED_USERNAME=$(echo -n "$USERNAME" | base64)
    ENCODED_PASSWORD=$(echo -n "$PASSWORD" | base64)
    log INFO "Authentication enabled with username: $USERNAME"
else
    log INFO "No authentication provided, proceeding with unauthenticated test."
fi

# Create temporary input file for openssl interaction
INPUT_FILE=$(mktemp)

{
    echo "EHLO localhost"
    if $AUTH_REQUIRED; then
        echo "AUTH LOGIN"
        echo "$ENCODED_USERNAME"
        echo "$ENCODED_PASSWORD"
    fi
    echo "MAIL FROM:<test@example.com>"
    echo "RCPT TO:<admin@example.com>"
    echo "DATA"
    echo "Subject: SMTP Test"
    echo "This is a test email."
    echo "."
    echo "QUIT"
} > "$INPUT_FILE"

log INFO "Connecting to $SMTP_SERVER on port $SMTP_PORT to test TLS support..."

# Test if the server supports TLS by using the openssl command
TLS_SUPPORT=$(openssl s_client -connect "$SMTP_SERVER:$SMTP_PORT" -starttls smtp -quiet 2>&1 | grep -i "starttls")
if [ -n "$TLS_SUPPORT" ]; then
    log INFO "TLS supported by $SMTP_SERVER."
else
    log WARN "$SMTP_SERVER does not support TLS or connection failed."
fi

# Run the full test by connecting to the server and issuing SMTP commands
log INFO "Running SMTP test on $SMTP_SERVER..."

openssl s_client -connect "$SMTP_SERVER:$SMTP_PORT" -starttls smtp -quiet < "$INPUT_FILE"

# Clean up the temporary file
rm -f "$INPUT_FILE"

log INFO "SMTP test completed."
