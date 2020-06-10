#FIXME - remove these SRC variables after grub-mender-grubenv PR#15 is merged into master
SRC_URI = "git://github.com/coreycothrum/grub-mender-grubenv;protocol=https;branch=master"
SRCREV  = "daec1e0df1f259e0f61b1ccb330ef70eb408d822"

do_configure_append() {
  echo "mender_kernela_part=$(get_part_number_from_device ${MENDER/KERNEL_PART_A})" >> ${B}/mender_grubenv_defines
  echo "mender_kernelb_part=$(get_part_number_from_device ${MENDER/KERNEL_PART_B})" >> ${B}/mender_grubenv_defines
  echo "initrd_imagetype=${MENDER/KERNEL_INITRAMFS_LINK_NAME}"                      >> ${B}/mender_grubenv_defines
}
