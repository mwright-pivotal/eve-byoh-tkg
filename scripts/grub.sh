#!/bin/bash

KERNEL_OPTIONS=(
 'console=tty1'
 'console=ttyS0,115200n8'
)


#Replace default cmdline args with KERNEL_OPTIONS, to redirect logs to serial console 
sudo sed -i -e \
    "s/.*GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"${KERNEL_OPTIONS[*]}\"/" \
    /etc/default/grub.d/50-cloudimg-settings.cfg

#Update grub to persist the change
sudo update-grub
