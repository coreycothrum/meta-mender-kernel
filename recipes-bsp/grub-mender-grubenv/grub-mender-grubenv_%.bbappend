FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "${@bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', 'file://90_mender_boot_grub.patch', '', d)}"

do_configure:append() {
  if ${@bb.utils.contains('MENDER_FEATURES', 'mender-partuuid', 'true', 'false', d)}; then
    echo "mender_kernela_part=${MENDER/KERNEL_PART_A_NUMBER}" >> ${B}/mender_grubenv_defines
    echo "mender_kernelb_part=${MENDER/KERNEL_PART_B_NUMBER}" >> ${B}/mender_grubenv_defines
    echo "mender_kernela_uuid=${@mender_get_partuuid_from_device(d, '${MENDER/KERNEL_PART_A}')}" >> ${B}/mender_grubenv_defines
    echo "mender_kernelb_uuid=${@mender_get_partuuid_from_device(d, '${MENDER/KERNEL_PART_B}')}" >> ${B}/mender_grubenv_defines
  else
    echo "mender_kernela_part=$(get_part_number_from_device ${MENDER/KERNEL_PART_A})" >> ${B}/mender_grubenv_defines
    echo "mender_kernelb_part=$(get_part_number_from_device ${MENDER/KERNEL_PART_B})" >> ${B}/mender_grubenv_defines
  fi

  echo "initrd_imagetype=${MENDER/KERNEL_INITRAMFS_LINK_NAME}"                      >> ${B}/mender_grubenv_defines
}

do_install:append() {
  oe_runmake -f ${S}/Makefile srcdir=${S} BOOT_DIR=${BOOT_DIR_LOCATION} EFI_DIR=${GRUB_CONF_BARE_LOCATION} DESTDIR=${D} install-legacy-tools
}
