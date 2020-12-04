DEPENDS += "openssl-native"

inherit user-key-store
fakeroot python do_sign_initramfs() {
    for img_fstype in d.getVar('INITRAMFS_FSTYPES').split():
      src = os.path.join( d.expand('${IMGDEPLOYDIR}'), d.expand('${IMAGE_NAME}.')      + img_fstype                              )
      dst = os.path.join( d.expand('${IMGDEPLOYDIR}'), d.expand('${IMAGE_LINK_NAME}.') + img_fstype + d.expand('${SB_FILE_EXT}') )

      if os.path.exists(src):
        uks_bl_sign(src, d)

        src += d.expand('${SB_FILE_EXT}')

        if os.path.exists(src):
          if os.path.islink(dst):
            os.remove(dst)

          os.symlink( os.path.basename(src), dst)

        else:
          bb.warn("%s does not exist, signing failed" % (src))

      else:
        bb.warn("%s does not exist to sign" % (src))
}

do_sign_initramfs[prefuncs] += "${@bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', 'check_deploy_keys', '', d)}"
do_sign_initramfs[prefuncs] += "${@'check_boot_public_key' if d.getVar('GRUB_SIGN_VERIFY', True) else ''}"

do_image_complete[prefuncs] += "do_sign_initramfs"
