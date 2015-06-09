This initramfs module does 2 things:
 * writes a file /run/network/dynamic-interfaces based on
   interfaces that were brought up during initramfs.
 * allows 'ip=' parameters on the command line to contain 'BOOTIF'

== /run/network/dynamic-interfaces ==
When network devices are brought up in the initramfs, klibc's ipconfig
tool writes files are named /run/net-<DEVNAME>.conf.  Their format is
described in /usr/share/doc/libklibc/README.ipconfig.gz.

This module translates those files to a interfaces(5) style file
and writes that to /run/network/dynamic-interfaces.
Each configured device is set to 'manual'. 
It writes 'dns-nameservers' and 'dns-search' entries as supported
by resolvconf(8).

The end result of this is that if you were only interested in interfaces
configured in the initramfs, you could have /etc/network/interfaces be a
symlink to /run/network/dynamic-interfaces.   Then, the
static-networking event will fire correctly as all configured network
devices will already be up, and configured network interfaces will
not be "bounced".

This is how the maas ephemeral images function in 12.04 and 12.10.  These
images are used to netboot to a read-only from iscsi root device.

=== 'ip=' and BOOTIF manipulation ===
When executed in the initramfs, the code in
'init-top/cloud-initramfs-dyn-netconf' will modify the global 'IP' and
'BOOTIF' variables according to the following rules:

 * if BOOTIF_DEFAULT=<name> is provided on the command line, but BOOTIF is
   not present, then BOOTIF will be set appropriately as if it were
   specified on the kernel command line with the MAC address of the
   device named 'name'.  Example:
     BOOTIF_DEFAULT=eth0
   will set the value of BOOTIF to be:
     BOOTIF=01-00-22-68-10-c1-e6

   Code that executes later in the initramfs will simply behave as if
   BOOTIF were on the command line initially.

 * if the literal string 'BOOTIF' appears inside the value of 'IP'
   (which is set from kernel command line parameter 'ip=...'), then
   it will be replaced with the device name that maps to the mac address
   specified in BOOTIF.

   Example:
     ip=::::foobar:BOOTIF BOOTIF=01-00-22-68-10-c1-e6
   will be effectively rendered as:
     ip=::::foobar:eth0
   before configure_networking would be run
