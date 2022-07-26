################################################################################
# the kernel recipe bundles and signs the kernel/initramfs. it does this
# in do_deploy:append. Because of this, the expected files need to be copied
# here w/ ROOTFS_POSTPROCESS_COMMAND.
#
# Refer to recipes-kernel/linux/mender-kernel-linux-yocto.inc
################################################################################
DEPENDS += "rsync-native"

do_mender_kernel_deploy_to_image_rootfs() {
  local bootdir="$(dirname ${MENDER_BOOT_PART_MOUNT_LOCATION})"
  local src_dir="${DEPLOY_DIR_IMAGE}/${MENDER/KERNEL_KERN_BUILD_STAGING_DIR}"
  local dst_dir="${IMAGE_ROOTFS}/${bootdir}"

  rm      -f "$dst_dir/"* || :
  install -d "$dst_dir/"

  rsync -avqI "$src_dir" "$dst_dir" --exclude "$(basename ${MENDER_BOOT_PART_MOUNT_LOCATION})"
}
ROOTFS_POSTPROCESS_COMMAND:append  = " do_mender_kernel_deploy_to_image_rootfs;"
