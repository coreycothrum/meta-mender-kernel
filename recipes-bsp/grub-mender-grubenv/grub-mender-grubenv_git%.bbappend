FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "${@bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', 'file://90_mender_boot_grub.patch', '', d)}"

do_configure_append() {
  echo "mender_kernela_part=$(get_part_number_from_device ${MENDER/KERNEL_PART_A})" >> ${B}/mender_grubenv_defines
  echo "mender_kernelb_part=$(get_part_number_from_device ${MENDER/KERNEL_PART_B})" >> ${B}/mender_grubenv_defines
  echo "initrd_imagetype=${MENDER/KERNEL_INITRAMFS_LINK_NAME}"                      >> ${B}/mender_grubenv_defines
}
