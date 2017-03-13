#!/bin/sh
echo "write ssh authorized keys"

mkdir -p ~/.ssh

cat > ~/.ssh/authorized_keys <<EOF
$SSH_AUTHORIZED_KEYS
EOF
