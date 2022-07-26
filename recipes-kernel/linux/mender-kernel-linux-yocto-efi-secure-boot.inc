#################################################################################
#################################################################################
# This task should be engineered out. It's only here because:
#     1. kernelimg is pulling everything from the deploy/staging area.
#        Nothing there is getting signed.
# and 2. SELoader cannot support verification of files outside the efi partition.
#        Since the kernel/initramfs *is* outside the efi partition, shim needs to
#        verify it. This requires:
#        1) bundle the initramfs/kernel so grub can use the chainloader cmd
#        2) sign the bundle w/ sbsign
#################################################################################
DEPENDS += "openssl-native"

inherit user-key-store

python do_mender_kernel_sign:append() {
  if not bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', True, False, d):
    bb.fatal("do_mender_kernel_sign should not execute if efi-secure-boot is not enabled")

  else:
    src_dir = os.path.abspath(d.expand('${DEPLOYDIR}/${MENDER/KERNEL_KERN_BUILD_STAGING_DIR}'))

    # bundled kernel/initramfs
    if bb.utils.contains('INITRAMFS_IMAGE_BUNDLE', '1', True, False, d):
      for ktype in d.expand('${KERNEL_IMAGETYPES}').split():
        bundle_name = "%s-%s.bin" % ( ktype, d.expand('${INITRAMFS_IMAGE}') )
        bundle_path = os.path.join( src_dir, bundle_name )

        sb_sign(bundle_path, bundle_path, d)

    # separate kernel/initramfs
    else:
      if d.getVar('INITRAMFS_IMAGE') or False:
        for fstype in d.expand('${INITRAMFS_FSTYPES}').split():
          initramfs_name = d.expand('${INITRAMFS_IMAGE}-${MACHINE}.') + fstype
          initramfs_path = os.path.join( src_dir, initramfs_name )

          sb_sign(initramfs_path, initramfs_path, d)

      for ktype in d.expand('${KERNEL_IMAGETYPES}').split():
        kernel_name = "%s" % ( ktype )
        kernel_path = os.path.join( src_dir, kernel_name )

        sb_sign(kernel_path, kernel_path, d)
}
#################################################################################
