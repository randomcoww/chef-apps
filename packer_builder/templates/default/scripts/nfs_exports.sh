#!/bin/bash
echo "setup NFS exports"

apt-get -y install nfs-kernel-server

cat > /etc/exports <<EOF
$NFS_EXPORTS
EOF
