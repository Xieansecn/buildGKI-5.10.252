properties() { '
kernel.string=marble kernel rebuild (PixelOS-compatible, boot.img kernel swap)
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=marble
device.name2=marblein
supported.versions=
supported.patchlevels=
'; }

# Boot partition kernel swap only. vendor_boot / vendor_dlkm are NEVER
# touched, so the stock DTB and vendor modules stay matched with the ROM.
block=boot;
is_slot_device=auto;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;
kernel=Image;

. tools/ak3-core.sh;

ui_print " "
ui_print "  marble kernel rebuild"
ui_print "  (replaces only the kernel inside boot.img)"
ui_print " "
