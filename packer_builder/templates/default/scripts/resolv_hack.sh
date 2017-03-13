#!/bin/sh

## Resolver keeps getting populated with something that doesn't work.
## Set to 10.0.2.3 according to qemu user mode networking spec and make sure it doesn't get overwritten.
## This file is replaced with a systemd-reolved symlink in a later step.
echo nameserver 10.0.2.3 > /etc/resolv.conf
chattr +i /etc/resolv.conf
