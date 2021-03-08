inherit mender-kernel-helpers

IMAGE_CLASSES += "          \
  mender-kernel-kernelimg   \
  mender-kernel-part-images \
"

################################################################################
mender_update_fstab_file_append() {
  mender_kernel_delete_kernel_parts ${IMAGE_ROOTFS}${sysconfdir}/fstab
}

################################################################################
python do_mender_kernel_checks() {
  if   bb.utils.contains('MENDER_FEATURES_ENABLE', 'mender-ubi', True, False, d):
    #TODO : know nothing about ubi support, didn't need it and didn't have time to look into it
    bb.fatal("mender-kernel does not currently support mender-ubi")

  elif bb.utils.contains('MENDER_FEATURES_ENABLE', 'mender-image-ubi', True, False, d):
    #TODO : know nothing about ubi support, didn't need it and didn't have time to look into it
    bb.fatal("mender-kernel does not currently support mender-image-ubi")

  elif bb.utils.contains('MENDER_FEATURES_ENABLE', 'mender-uboot'    , True, False, d):
    #TODO : probably would require mender/uboot patches
    bb.fatal("mender-kernel does not currently support mender-uboot")

  elif bb.utils.contains('MENDER_FEATURES_ENABLE', 'mender-partuuid'   , True, False, d):
    #TODO : just haven't looked into it at all
    bb.fatal("mender-kernel does not currently support mender-partuuid")

  ##############################################################################
  elif int(d.expand('${MENDER_BOOT_PART_SIZE_MB}', 0)) <= 0:
    bb.fatal("mender-kernel requires MENDER_BOOT_PART_SIZE_MB > 0")

  elif int(d.expand('${MENDER/KERNEL_PART_SIZE_MB}', 0)) <= 0:
    bb.fatal("mender-kernel requires MENDER/KERNEL_PART_SIZE_MB > 0")

  elif bb.utils.contains('MENDER_FEATURES_ENABLE', 'mender-growfs-data', True, False, d):
    bb.fatal("mender-kernel does not support mender-growfs-data: \n"           \
             "mender-growfs-data and MENDER_EXTRA_PARTS are mutually exclusive")

  ##############################################################################
  if   bb.utils.contains('INITRAMFS_IMAGE_BUNDLE', '1', True, False, d):
    if not d.getVar('INITRAMFS_IMAGE', None):
      bb.fatal("INITRAMFS_IMAGE_BUNDLE is set w/o defining an INITRAMFS_IMAGE")

  if   bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', True, False, d):
    if bb.utils.contains('SIGNING_MODEL'  , 'sample'         , True, False, d):
      bb.warn("efi-secure-boot is using sample SIGNING_MODEL, this is unsecure. Change before deploying.")

    if d.getVar('INITRAMFS_IMAGE', None):
      if not bb.utils.contains('INITRAMFS_IMAGE_BUNDLE', '1', True, False, d):
        bb.fatal("mender-kernel requires INITRAMFS_IMAGE_BUNDLE when using an INITRAMFS_IMAGE and efi-secure-boot")
}
addhandler do_mender_kernel_checks
do_mender_kernel_checks[eventmask] = "bb.event.ParseCompleted"
