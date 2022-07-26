################################################################################
# To avoid circular dependencies w/ initramfs/bundle, this has to be done after
# do_package*. Not great, because now ${D}/${bootdir} (and the boot dir of the
# final IMAGE_ROOTFS) doesn't match what meta-kernel expects.
#
# Instead of doing anything with do_install, move the needed/expected files into
# a staging area under DEPLOYDIR. kernelimg will pull from this.
#
# The IMAGE_ROOTFS must match though, or mender updates will fail. kernelimg is
# only used for disk provisioning. During updates the kernel partition is
# updated from the updated partition's IMAGE_ROOTFS via rsync.
#
# A ROOTFS_POSTPROCESS_COMMAND (/conf/include/mender-kernel-image.inc) will sync
# the staging directory and IMAGE_ROOTFS bootdir.
#
# This seems super hacky to me, but any google/reference I've pulled up is doing
# it the same way.
################################################################################
do_deploy:append() {
    local bootdir="$(dirname ${MENDER_BOOT_PART_MOUNT_LOCATION})"
    local src_dir="${B}/${KERNEL_OUTPUT_DIR}"
    local dst_dir="${DEPLOYDIR}/${MENDER/KERNEL_KERN_BUILD_STAGING_DIR}"

    rm      -fr "$dst_dir/"
    install -d  "$dst_dir/"

    for ktype in ${KERNEL_IMAGETYPES}; do
      install -m 0644 "$src_dir/$ktype" "$dst_dir/" || :
    done

    if [ ! -z "${INITRAMFS_IMAGE}" -a x"${INITRAMFS_IMAGE_BUNDLE}" = x1 ]; then
      for ktype in ${KERNEL_IMAGETYPES}; do
        local src_name="$ktype.initramfs"
        local dst_name="$ktype-${INITRAMFS_IMAGE}.bin"
        local lnr_name="$ktype"

        install -d                            "$dst_dir/"
        install -m  0644 "$src_dir/$src_name" "$dst_dir/$dst_name"
        rm      -fr                                                "$dst_dir/$lnr_name"
        ln      -rs                           "$dst_dir/$dst_name" "$dst_dir/$lnr_name"
      done
    elif [ -n "${INITRAMFS_IMAGE}"  ]; then
      local src_dir="${DEPLOY_DIR_IMAGE}"

      for fstype in ${INITRAMFS_FSTYPES}; do
        local src_name="${INITRAMFS_IMAGE}-${MACHINE}.$fstype"
        local dst_name="$src_name"
        local lnr_name="${MENDER/KERNEL_INITRAMFS_LINK_NAME}"

        install -d                            "$dst_dir/"
        install -m  0644 "$src_dir/$src_name" "$dst_dir/$dst_name"
        rm      -fr                                                "$dst_dir/$lnr_name"
        ln      -rs                           "$dst_dir/$dst_name" "$dst_dir/$lnr_name"
      done
    fi
}

do_deploy[postfuncs] += " do_mender_kernel_sign"

################################################################################
python do_mender_kernel_sign() {
  if not bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', True, False, d):
    bb.warn('reconsider: efi-secure-boot is not enabled, not signing kernel/initramfs/bundle')
}

require ${@bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', 'mender-kernel-linux-yocto-efi-secure-boot.inc', '', d)}
################################################################################
