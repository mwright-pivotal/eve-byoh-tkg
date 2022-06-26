#!/bin/bash -eux

echo "==> Remove ssh server keys"
rm -rf /etc/ssh/*_host_*

echo "==> Remove caches"
find /var/cache -type f -exec rm -rf {} \;

echo "==> Empty log files"
find /var/log -type f | while read f; do echo -ne '' > "$f"; done;

echo "==> Remove the local machine ID"
if [ -f /etc/machine-id ]; then
    rm -f /etc/machine-id
    touch /etc/machine-id
fi
if [ -f /var/lib/dbus/machine-id ]; then
    rm -f /var/lib/dbus/machine-id
    touch /var/lib/dbus/machine-id
fi
