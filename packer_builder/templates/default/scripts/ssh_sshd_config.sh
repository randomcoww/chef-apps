#!/bin/sh
echo "configure key only SSH"

cat > /etc/ssh/sshd_config <<EOF
UsePrivilegeSeparation sandbox
Subsystem sftp internal-sftp

PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
EOF
